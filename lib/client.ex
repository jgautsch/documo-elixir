defmodule Documo.Client do
  @moduledoc """
  Client responsible for making requests to Documo and handling the responses.
  """

  alias HTTPoison.Error
  alias HTTPoison.Response
  alias Documo.Config

  use HTTPoison.Base

  @type client_response :: {:ok, map, list} | {:error, map}

  # #########################
  # HTTPoison.Base callbacks
  # #########################

  def process_request_headers(headers) do
    Config.api_version()
    |> default_headers()
    |> Map.merge(Map.new(headers))
    |> Enum.into([])
  end

  def process_response_body(""), do: %{}

  def process_response_body(body) do
    Jason.decode!(body)
  end

  # #########################
  # Client API
  # #########################

  @spec get_request(String.t(), HTTPoison.Base.headers()) :: client_response()
  def get_request(url, headers \\ []) do
    url
    |> get(headers, build_options())
    |> handle_response()
  end

  @spec post_request(
          String.t(),
          {:form, list} | {:multipart, list} | String.t(),
          HTTPoison.Base.headers()
        ) ::
          client_response()
  def post_request(url, body, headers \\ []) do
    url
    |> post(body, headers, build_options())
    |> handle_response()
  end

  @spec delete_request(String.t(), HTTPoison.Base.headers()) :: client_response()
  def delete_request(url, headers \\ []) do
    url
    |> delete(headers, build_options())
    |> handle_response()
  end

  # #########################
  # Response handlers
  # #########################

  @spec handle_response({:ok | :error, Response.t() | Error.t()}) :: client_response()
  defp handle_response({:ok, %{body: body, headers: headers, status_code: code}})
       when code >= 200 and code < 300 do
    {:ok, body, headers}
  end

  defp handle_response({:ok, %{body: body}}) do
    {:error, body["error"]}
  end

  defp handle_response({:error, error = %Error{}}) do
    {:error, %{"message" => Error.message(error)}}
  end

  @spec build_options() :: Keyword.t()
  defp build_options() do
    [recv_timeout: :infinity]
  end

  @spec default_headers(String.t() | nil) :: %{String.t() => String.t()}
  defp default_headers(nil),
    do: %{
      "User-Agent" => "Documo/v1 ElixirBindings/#{Config.client_version()}",
      "Authorization" => "Basic #{Config.api_key()}"
    }

  defp default_headers(api_version),
    do:
      Map.merge(default_headers(nil), %{
        "Documo-Version" => api_version
      })
end
