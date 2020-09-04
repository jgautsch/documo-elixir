defmodule Documo.Util do
  @moduledoc """
  Module responsible for transforming arguments for requests.
  """

  @type content_type :: :multipart | :form

  @doc """
  Transforms a map of request params to a URL encoded query string.

  ## Example
    iex> Documo.Util.build_query_string(%{count: 1, include: ["total_count"], metadata: %{name: "Larry"}})
    "count=1&include%5B%5D=total_count&metadata%5Bname%5D=Larry"
  """
  @spec build_query_string(map) :: String.t()
  def build_query_string(params) when is_map(params) do
    params
    |> Enum.reduce([], &(&2 ++ transform_argument(&1, :form)))
    |> URI.encode_query()
  end

  @doc """
  Transforms a map to a tuple recognized by HTTPoison/hackney for use as a
  multipart request body.
  ## Example
    iex> Documo.Util.build_body(%{description: "body", to: %{name: "Larry", species: "Lobster"}, front: %{local_path: "a/b/c.pdf"}})
    {:multipart, [{"description", "body", [{"content-type", "multipart/form-data"}]}, {:file, "a/b/c.pdf", {"form-data", [{"name", "front"}, {"filename", "c.pdf"}]}, []}, {"to[name]", "Larry"}, {"to[species]", "Lobster"}]}
  """
  @spec build_body(map, content_type()) :: {:multipart, list} | {:form, list}
  def build_body(body, content_type \\ :multipart) when is_map(body) do
    do_build_body(body, content_type)
  end

  defp do_build_body(body, :multipart) when is_map(body) do
    {:multipart, Enum.reduce(body, [], &(&2 ++ transform_argument(&1, :multipart)))}
  end

  defp do_build_body(body, :form) when is_map(body) do
    {:form, Enum.reduce(body, [], &(&2 ++ transform_argument(&1, :form)))}
  end

  @doc """
  Transforms a map to a list of tuples recognized by HTTPoison/hackeny for use
  as request headers.
  ## Example
    iex> Documo.Util.build_headers(%{"Documo-Version" => "2020-08-31", "Idempotency-Key" => "abc123"})
    [{"Documo-Version", "2020-08-31"}, {"Idempotency-Key", "abc123"}]
  """
  @spec build_headers(map) :: HTTPoison.Base.headers()
  def build_headers(headers) do
    headers
    |> Enum.to_list()
    |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)
  end

  @spec transform_argument({any, any}, content_type()) :: list
  defp transform_argument({:merge_variables, v}, content_type),
    do: transform_argument({"merge_variables", v}, content_type)

  defp transform_argument({"merge_variables", v}, _content_type) do
    [{"merge_variables", Jason.encode!(v), [{"Content-Type", "application/json"}]}]
  end

  defp transform_argument({k, v}, _content_type) when is_list(v) do
    Enum.map(v, fn e ->
      {"#{to_string(k)}[]", to_string(e)}
    end)
  end

  # For context on the format of the struct see:
  # https://github.com/benoitc/hackney/issues/292
  defp transform_argument({k, %{local_path: file_path}}, _content_type) do
    [
      {:file, file_path,
       {"form-data", [{"name", to_string(k)}, {"filename", Path.basename(file_path)}]}, []}
    ]
  end

  defp transform_argument({k, v}, _content_type) when is_map(v) do
    Enum.map(v, fn {sub_k, sub_v} ->
      {"#{to_string(k)}[#{to_string(sub_k)}]", to_string(sub_v)}
    end)
  end

  defp transform_argument({k, v}, :multipart) do
    [{to_string(k), to_string(v), [{"content-type", "multipart/form-data"}]}]
  end

  defp transform_argument({k, v}, :form) do
    # [{to_string(k), URI.encode_www_form(to_string(v))}]
    [{to_string(k), to_string(v)}]
  end
end
