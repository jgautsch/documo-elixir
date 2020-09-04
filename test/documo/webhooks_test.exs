defmodule Documo.WebhooksTest do
  use ExUnit.Case

  alias Documo.Webhooks

  setup do
    bypass = Bypass.open()

    initial_api_host = Application.get_env(:documo_elixir, :api_host)
    Application.put_env(:documo_elixir, :api_host, "http://localhost:#{bypass.port}")

    on_exit(fn ->
      Application.put_env(:documo_elixir, :api_host, initial_api_host)
    end)

    {:ok, bypass: bypass}
  end

  describe "list/2" do
    test "lists webhooks", %{bypass: bypass} do
      resp = %{"rows" => []}

      Bypass.expect_once(bypass, fn conn ->
        assert "/webhooks" == conn.request_path
        assert "GET" == conn.method

        conn = Plug.Conn.fetch_query_params(conn)

        assert conn.query_params == %{}

        Plug.Conn.resp(conn, 200, Jason.encode!(resp))
      end)

      {:ok, body, _headers} = Webhooks.list()
      assert body == resp
    end
  end
end
