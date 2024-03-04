defmodule Gps do
  use GenServer
  @moduledoc """
  Documentation for `Gps`.
  """

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_args) do
    {:ok, pid} = Nerves.UART.start_link()
    :ok = Nerves.UART.open(pid, "ttyAMA0", speed: 9600)
    {:ok, pid}
  end
   
  def handle_info({:nerves_uart, serial_port_id, data}, state) do
    IO.inspect data
    {:noreply, state}
  end

  def handle_call(message, state) do
    IO.inspect "Unhandled message: #{message}"
    {:noreply, state}
  end
end
