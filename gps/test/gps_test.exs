defmodule GpsTest do
  use ExUnit.Case
  doctest Gps

  test "handle_info" do 
    default_state = %{
      messages: :queue.new(),
      message_limit: 50,
      in_progress_message: ""
    }

    File.stream!("./test/gps_input.txt")
      |> Enum.reduce(default_state, fn line, state -> 
        {:noreply, state } = Gps.handle_info({ :nerves_uart, "doesn't matter", line }, state)
        state
      end)
      |> IO.inspect()
  end
end
