defmodule DocumoTest do
  use ExUnit.Case
  doctest Documo

  test "greets the world" do
    assert Documo.hello() == :world
  end
end
