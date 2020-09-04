defmodule Documo.Url do
  alias Documo.Config
  alias Documo.Util

  def resource_url(resource_path) when is_binary(resource_path) do
    Path.join([Config.api_host(), resource_path])
  end

  def resource_url(resource_path, params) when params == %{} do
    resource_url(resource_path)
  end

  def resource_url(resource_path, params) when is_binary(resource_path) and is_map(params) do
    "#{resource_url(resource_path)}?#{Util.build_query_string(params)}"
  end
end
