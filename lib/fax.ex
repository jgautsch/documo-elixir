defmodule Documo.Fax do
  @moduledoc """
  Module implementing the Documo fax API.
  """

  alias Documo.Client
  alias Documo.Url
  alias Documo.Util

  def info(message_id, headers \\ %{}) when is_binary(message_id) do
    "/v1/fax/#{message_id}/info"
    |> Url.resource_url()
    |> Client.get_request(Util.build_headers(headers))
  end

  @doc """
  Ref: https://docs.documo.com/#send-a-fax
  """
  # @spec send(String.t(), map, map) :: Client.client_response()
  def send(params \\ %{}, headers \\ %{}) do
    headers = Map.merge(headers, %{"Content-Type" => "multipart/form-data"})
    body = Util.build_body(params, :multipart)

    "/v1/faxes"
    |> Url.resource_url()
    |> Client.post_request(body, Util.build_headers(headers))
  end

  @doc """
  Ref: https://docs.documo.com/?shell#resend-fax

  NB: `params` has a `recipientFax` to change who to send the fax to.
  """
  def resend(message_id, params \\ %{}, headers \\ %{}) do
    headers = Map.merge(headers, %{"Content-Type" => "application/x-www-form-urlencoded"})
    params = Map.merge(%{messageId: message_id}, params)
    body = Util.build_body(params, :form)

    "/v1/fax/resend"
    |> Url.resource_url()
    |> Client.post_request(body, Util.build_headers(headers))
  end

  def history(params \\ %{}, headers \\ %{}) do
    "/v1/fax/history"
    |> Url.resource_url(params)
    |> Client.get_request(Util.build_headers(headers))
  end
end
