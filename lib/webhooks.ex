defmodule Documo.Webhooks do
  @moduledoc """
  Module implementing the Documo webhooks API.
  """

  alias Documo.Client
  alias Documo.Url
  alias Documo.Util

  @doc """
  Ref: https://docs.documo.com/#get-webhooks
  """
  @spec list(map, map) :: Client.client_response()
  def list(params \\ %{}, headers \\ %{}) do
    "/webhooks"
    |> Url.resource_url(params)
    |> Client.get_request(Util.build_headers(headers))
  end
end
