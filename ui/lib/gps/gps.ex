defmodule Gps do
  use GenServer

  @moduledoc """
  Documentation for `Gps`.
  """

  defstruct in_progress_message: ""

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      %Gps{},
      opts
    )
  end

  def init(state) do
    {:ok, pid} = Circuits.UART.start_link()
    :ok = Circuits.UART.open(pid, "ttyAMA0", speed: 9600)
    {:ok, state}
  end

  def handle_info({:circuits_uart, _serial_port_id, data}, state) do
    case build_message(data, state.in_progress_message) do
      {existing_message} ->
        {:noreply, Map.put(state, :in_progress_message, existing_message)}

      {complete_message, new_message} ->
        {
          :noreply,
          Map.put(state, :in_progress_message, new_message)
          |> then(fn state -> 
            Phoenix.PubSub.broadcast!(Ui.PubSub, "gps", {:new_message, complete_message})
            state 
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
end
