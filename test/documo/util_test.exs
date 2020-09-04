defmodule Documo.UtilTest do
  use ExUnit.Case
  doctest Documo.Util

  alias Documo.Util

  describe "build_body/2" do
    test "build_body(params, :multipart)" do
      params = %{
        faxNumber: "15554443322",
        attachments: %{local_path: "test/assets/dummy.pdf"}
      }

      assert Util.build_body(params, :multipart) ==
               {:multipart,
                [
                  {:file, "test/assets/dummy.pdf",
                   {"form-data", [{"name", "attachments"}, {"filename", "dummy.pdf"}]}, []},
                  {"faxNumber", "15554443322", [{"content-type", "multipart/form-data"}]}
                ]}
    end

    test "build_body(params, :form)" do
      params = %{
        messageId: "cddf46b4-8ec6-45c2-9eab-72e92f26f272",
        recipientFax: "14445553322"
      }

      assert Util.build_body(params, :form) ==
               {:form,
                [
                  {"messageId", "cddf46b4-8ec6-45c2-9eab-72e92f26f272"},
                  {"recipientFax", "14445553322"}
                ]}
    end
  end
end
