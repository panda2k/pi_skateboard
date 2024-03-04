defmodule GpsTest do
  use ExUnit.Case
  doctest Gps

  test "greets the world" do
    assert Gps.hello() == :world
  end
end
