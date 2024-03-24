defmodule Gps do
  use GenServer

  @moduledoc """
  Documentation for `Gps`.
  """

  def start_link(opts \\ [message_limit: 20]) do
    GenServer.start_link(
      __MODULE__,
      %{messages: :queue.new(), message_limit: opts[:message_limit], in_progress_message: ""},
      opts
    )
  end

  def init(_args) do
    {:ok, pid} = Nerves.UART.start_link()
    :ok = Nerves.UART.open(pid, "ttyAMA0", speed: 9600)
    {:ok, pid}
  end

  def handle_info({:nerves_uart, _serial_port_id, data}, state) do
    case build_message(data, state.in_progress_message) do
      {existing_message} ->
        {:noreply, Map.put(state, :in_progress_message, existing_message)}

      {existing_message, new_message} ->
        {
          :noreply,
          Map.put(state, :in_progress_message, new_message)
          |> then(fn state -> 
            case existing_message do 
              << _head::binary-size(3), "GGA", _rest::binary >> -> 
                Map.put(state, :messages, :queue.in(:binary.split(existing_message, ",", [:global]), state.messages))
              _ -> state
            end
          end)
          |> then(fn state ->
            if :queue.len(state.messages) > state.message_limit do
              Map.put(state, :messages, :queue.drop(state.messages))
            else
              state
            end
          end)
        } 
    end
  end
   
  def build_message(new_fragment, existing_message) do
    new_fragment = :binary.split(new_fragment, "\\r") 
      |> Enum.flat_map(fn s -> :binary.split(s, "\\n") end)
      |> Enum.flat_map(fn s -> :binary.split(s, "\n") end)
      |> Enum.filter(fn s -> s != "" end)
    case new_fragment do
      # empty string so new message should be on next line
      [] ->
        {existing_message}
    
      # string has new GGA message 
      [<<"$", new_message::binary>>] -> 
        { existing_message, "$" <> new_message }
      
      # string has continuing message 
      [msg] ->
        if existing_message != "", do: {existing_message <> msg}, else: {existing_message}

      # string has continuing message and start of new message (no new line)
      [msg, <<"$", new_msg::binary>>] ->
        {existing_message <> msg, "$" <> new_msg}
    end
  end

  def handle_call(message, state) do
    IO.inspect("Unhandled message: #{message}")
    {:noreply, state}
  end
end
