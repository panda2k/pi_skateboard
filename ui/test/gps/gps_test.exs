defmodule GpsTest do
  use ExUnit.Case
  doctest Gps

  test "handle_info" do 
    File.stream!("./test/gps/gps_input.txt")
      |> Enum.reduce(%Gps{}, fn line, state -> 
        {:noreply, state } = Gps.handle_info({ :circuits_uart, "doesn't matter", line }, state)
        state
      end)
      |> IO.inspect()
  end
end
