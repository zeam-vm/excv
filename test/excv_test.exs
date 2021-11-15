defmodule ExcvTest do
  use ExUnit.Case
  doctest Excv

  test "greets the world" do
    assert Excv.hello() == :world
  end
end
