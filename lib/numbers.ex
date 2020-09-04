defmodule Documo.Numbers do
  @moduledoc """
  Module implementing the Documo fax numbers API.
  """

  alias Documo.Client
  alias Documo.Url
  alias Documo.Util

  @doc """
  Ref: https://docs.documo.com/#retrieve-fax-numbers
  """
  @spec list(map, map) :: Client.client_response()
  def list(params \\ %{}, headers \\ %{}) do
    "/v1/numbers"
    |> Url.resource_url(params)
    |> Client.get_request(Util.build_headers(headers))
  end

  @doc """
  NB: Use "npa" param to search for specific area code.

  Ref: https://docs.documo.com/#search-for-available-numbers
  """
  @spec search(map, map) :: Client.client_response()
  def search(params \\ %{}, headers \\ %{}) when is_map(params) do
    "/v1/numbers/provision/search"
    |> Url.resource_url(params)
    |> Client.get_request(Util.build_headers(headers))
  end

  @doc """
  Provision a fax number. Provisioned fax numbers
  incur a monthly charge. Provision type is
  hard-coded to `"order"` presently in this library.

  The number being provisioned must be passed in
  E164 format, and must have appeared in a number search
  within the last 24 hours.

  Ref: https://docs.documo.com/#provision-fax-numbers
  """
  @spec provision(String.t(), map) :: Client.client_response()
  def provision("+1" <> <<fax_number::binary-10>>, headers \\ %{}) do
    headers = Map.merge(headers, %{"Content-Type" => "application/x-www-form-urlencoded"})

    params = %{
      type: "order",
      numbers: "+1" <> fax_number
    }

    body = Util.build_body(params, :form)

    "/v1/numbers/provision"
    |> Url.resource_url()
    |> Client.post_request(body, Util.build_headers(headers))
  end

  @doc """
  Ref: https://docs.documo.com/#release-number
  """
  @spec release(String.t(), map) :: Client.client_response()
  def release(number_id, headers \\ %{}) when is_binary(number_id) do
    "/v1/numbers/#{number_id}/release"
    |> Url.resource_url()
    |> Client.delete_request(Util.build_headers(headers))
  end
end
