defmodule Documo.FaxTest do
  use ExUnit.Case

  alias Documo.Fax

  setup do
    bypass = Bypass.open()

    initial_api_host = Application.get_env(:documo_elixir, :api_host)
    Application.put_env(:documo_elixir, :api_host, "http://localhost:#{bypass.port}")

    on_exit(fn ->
      Application.put_env(:documo_elixir, :api_host, initial_api_host)
    end)

    {:ok, bypass: bypass}
  end

  describe "send/3" do
    test "sends a fax from a local file", %{bypass: bypass} do
      resp = build(:send_response_success)

      Bypass.expect_once(bypass, fn conn ->
        assert "/v1/faxes" == conn.request_path
        assert "POST" == conn.method

        parser_opts = Plug.Parsers.init(parsers: [:multipart])
        conn = Plug.Parsers.call(conn, parser_opts)

        assert %{
                 "faxNumber" => "15554443322",
                 "attachments" => upload
               } = conn.params

        assert %Plug.Upload{
                 content_type: "application/pdf",
                 filename: "dummy.pdf"
               } = upload

        Plug.Conn.resp(conn, 200, Jason.encode!(resp))
      end)

      {:ok, body, _headers} =
        Fax.send(%{
          faxNumber: "15554443322",
          attachments: %{local_path: "test/assets/dummy.pdf"}
        })

      assert body == resp
    end
  end

  describe "resend/3" do
    test "resends a fax with a given `message_id`", %{bypass: bypass} do
      resp = build(:resend_response_success)
      message_id = "123abc"

      Bypass.expect_once(bypass, fn conn ->
        assert "/v1/fax/resend" == conn.request_path
        assert "POST" == conn.method

        parser_opts = Plug.Parsers.init(parsers: [:urlencoded, :multipart])
        conn = Plug.Parsers.call(conn, parser_opts)

        assert conn.params == %{"messageId" => message_id}

        Plug.Conn.resp(conn, 200, Jason.encode!(resp))
      end)

      {:ok, body, _headers} = Fax.resend(message_id)

      assert body == resp
    end
  end

  def build(factory, extra_attrs \\ %{})

  def build(:send_response_success, attrs) do
    Map.merge(
      %{
        "messageId" => "00000000-0000-0000-0000-000000000000",
        "pagesComplete" => 0,
        "isArchived" => false,
        "isFilePurged" => false,
        "status" => "processing",
        "faxNumber" => "+15554443322",
        "faxCsid" => "mFax",
        "faxCallerId" => "5556667788",
        "direction" => "outbound",
        "accountId" => "00000000-0000-0000-0000-000000000000",
        "country" => "US",
        "pagesCount" => 1,
        "channelType" => "api",
        "createdAt" => "2020-09-02T21:33:01.000Z",
        "processingStatusName" => "processing",
        "classificationLabel" => "outbound",
        "deliveryId" => nil,
        "watermark" => nil,
        "messageNumber" => nil,
        "duration" => nil,
        "faxECM" => nil,
        "faxSpeed" => nil,
        "faxDetected" => nil,
        "faxProtocol" => nil,
        "faxAttempt" => nil,
        "faxbridgeId" => nil,
        "errorInfo" => nil,
        "errorCode" => nil,
        "resultCode" => nil,
        "resultInfo" => nil,
        "resolvedDate" => nil,
        "deletedAt" => nil,
        "faxbridge_id" => nil,
        "users" => [
          %{
            "avatarPath" => nil,
            "userId" => "00000000-0000-0000-0000-000000000000",
            "uuid" => "00000000-0000-0000-0000-000000000000",
            "email" => "test@example.com",
            "firstName" => "Test",
            "lastName" => "User",
            "accountId" => "00000000-0000-0000-0000-000000000000",
            "avatar" => nil,
            "UserFax" => %{
              "viewStatus" => true,
              "downloadStatus" => false
            }
          }
        ],
        "account" => %{
          "uuid" => "00000000-0000-0000-0000-000000000000",
          "accountNumber" => "1111111111",
          "accountName" => "SomeOrg",
          "accountType" => "customer"
        },
        "tags" => [],
        "faxbridge" => nil,
        "contacts" => []
      },
      attrs
    )
  end

  def build(:resend_response_success, attrs) do
    Map.merge(
      %{
        "errors" => [],
        "success" => [
          %{
            "accountId" => "00000000-0000-0000-0000-000000000000",
            "channelType" => "api",
            "country" => "US",
            "createdAt" => "2020-09-03T18:47:33.540Z",
            "direction" => "outbound",
            "faxCallerId" => "5554443322",
            "faxCsid" => "mFax",
            "faxNumber" => "+15556667788",
            "isArchived" => false,
            "isFilePurged" => false,
            "messageId" => "00000000-0000-0000-0000-000000000000",
            "pagesComplete" => 0,
            "pagesCount" => 1,
            "status" => "processing"
          }
        ]
      },
      attrs
    )
  end
end
