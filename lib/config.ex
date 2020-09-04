defmodule Documo.Config do
  @client_version Mix.Project.config()[:version]
  @default_api_host "https://api.documo.com"

  defmodule MissingAPIKeyError do
    @moduledoc """
    Exception for when a request is made without an API key.
    """

    defexception message: """
                 The api_key setting is required to make requests to Documo.
                 Please configure :api_key in config.exs or set the DOCUMO_API_KEY
                 environment variable.

                 config :documo_elixir, api_key: API_KEY
                 """
  end

  @spec client_version :: String.t()
  def client_version(), do: @client_version

  def api_host() do
    Application.get_env(:documo_elixir, :api_host, @default_api_host)
  end

  @spec api_version :: String.t() | nil
  def api_version(),
    do: Application.get_env(:documo_elixir, :api_version, System.get_env("DOCUMO_API_VERSION"))

  @spec api_key(atom) :: String.t()
  def api_key(env_key \\ :api_key) do
    case Application.get_env(:documo_elixir, env_key, System.get_env("DOCUMO_API_KEY")) ||
           :not_found do
      :not_found -> raise MissingAPIKeyError
      value -> value
    end
  end
end
