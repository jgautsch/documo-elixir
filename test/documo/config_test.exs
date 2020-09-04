defmodule Documo.ConfigTest do
  use ExUnit.Case

  alias Documo.Config
  alias Documo.Config.MissingAPIKeyError

  describe "api_key/1" do
    test "raises MissingAPIKeyError if no API key is found" do
      assert_raise(MissingAPIKeyError, fn ->
        api_key = System.get_env("DOCUMO_API_KEY")
        System.delete_env("DOCUMO_API_KEY")
        Config.api_key(nil)
        System.put_env("DOCUMO_API_KEY", api_key)
      end)
    end
  end
end
