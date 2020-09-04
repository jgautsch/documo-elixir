defmodule Documo.NumbersTest do
  use ExUnit.Case

  alias Documo.Numbers

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
    test "lists fax numbers", %{bypass: bypass} do
      resp = %{"rows" => []}

      Bypass.expect_once(bypass, fn conn ->
        assert "/v1/numbers" == conn.request_path
        assert "GET" == conn.method

        conn = Plug.Conn.fetch_query_params(conn)

        assert conn.query_params == %{}

        Plug.Conn.resp(conn, 200, Jason.encode!(resp))
      end)

      {:ok, body, _headers} = Numbers.list()
      assert body == resp
    end
  end

  describe "search/2" do
    test "searches fax numbers", %{bypass: bypass} do
      resp = %{
        "result" => [
          %{
            "number" => "+15554443322",
            "number_e164" => "+15554443322",
            "preferable" => true,
            "regional_data" => %{
              "country_iso" => "US",
              "rate_center" => "SPENCER MILL",
              "state" => "TN"
            }
          }
        ]
      }

      Bypass.expect_once(bypass, fn conn ->
        assert "/v1/numbers/provision/search" == conn.request_path
        assert "GET" == conn.method

        conn = Plug.Conn.fetch_query_params(conn)

        assert conn.query_params == %{"npa" => "619"}

        Plug.Conn.resp(conn, 200, Jason.encode!(resp))
      end)

      {:ok, body, _headers} = Numbers.search(%{npa: "619"})
      assert body == resp
    end
  end

  describe "provision/2" do
    test "provisions a fax number", %{bypass: bypass} do
      resp = build(:provision_response_success)

      Bypass.expect_once(bypass, fn conn ->
        assert "/v1/numbers/provision" == conn.request_path
        assert "POST" == conn.method

        parser_opts = Plug.Parsers.init(parsers: [:urlencoded, :multipart], pass: ["*/*"])
        conn = Plug.Parsers.call(conn, parser_opts)

        assert conn.params == %{
                 "type" => "order",
                 "numbers" => "+15554443322"
               }

        Plug.Conn.resp(conn, 200, Jason.encode!(resp))
      end)

      {:ok, body, _headers} = Numbers.provision("+15554443322")
      assert body == resp
    end
  end

  describe "release/2" do
    test "releases a fax number", %{bypass: bypass} do
      number_id = "123"

      Bypass.expect_once(bypass, fn conn ->
        assert "/v1/numbers/#{number_id}/release" == conn.request_path
        assert "DELETE" == conn.method

        Plug.Conn.resp(conn, :no_content, "")
      end)

      {:ok, body, _headers} = Numbers.release(number_id)
      assert body == %{}
    end
  end

  defp build(resource, extra_attrs \\ %{})

  defp build(:provision_response_success, _attrs) do
    [
      %{
        "uuid" => "00000000-0000-0000-0000-000000000000",
        "number" => "8440000000",
        "pendingUntil" => nil,
        "ownedBy" => "00000000-0000-0000-0000-000000000000",
        "managedBy" => "00000000-0000-0000-0000-000000000000",
        "createdAt" => "2017-06-26T15:35:13.000Z",
        "owner" => %{
          "uuid" => "00000000-0000-0000-0000-000000000000",
          "accountNumber" => "1200000000",
          "accountName" => "Night’s Watch",
          "accountType" => "customer"
        },
        "manager" => %{
          "uuid" => "00000000-0000-0000-0000-000000000000",
          "accountNumber" => "1200000000",
          "accountName" => "Night’s Watch",
          "accountType" => "customer"
        }
      }
    ]
  end
end
