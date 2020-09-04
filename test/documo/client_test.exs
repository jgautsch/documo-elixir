defmodule Documo.ClientTest do
  use ExUnit.Case

  alias Documo.Client
  alias Plug.Conn

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "get_request/2" do
    test "handles 2XX responses", %{bypass: bypass} do
      response_body = %{
        "data" => %{
          "foo" => "bar"
        }
      }

      Bypass.expect(bypass, fn conn ->
        conn
        |> Conn.put_resp_header("HeaderKey", "HeaderValue")
        |> Conn.resp(203, Jason.encode!(response_body))
      end)

      {:ok, body, headers} = Client.get_request(endpoint_url(bypass.port))
      assert response_body == body
      assert Enum.member?(headers, {"HeaderKey", "HeaderValue"})
    end

    test "handles non-2XX responses", %{bypass: bypass} do
      response_body = %{
        "error" => %{
          "name" => "NotAllowedError",
          "message" => "Non trial mFax plan required."
        }
      }

      Bypass.expect(bypass, fn conn ->
        Conn.resp(conn, 404, Jason.encode!(response_body))
      end)

      {:error, error} = Client.get_request(endpoint_url(bypass.port))
      assert error == response_body["error"]
    end

    test "handles connection errors", %{bypass: bypass} do
      Bypass.down(bypass)
      {:error, %{"message" => error}} = Client.get_request(endpoint_url(bypass.port))
      assert error == ":econnrefused"
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"
end
