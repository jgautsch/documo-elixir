defmodule Documo.MixProject do
  use Mix.Project

  @name "Documo"
  @version "0.1.0"
  @repo_url "https://github.com/jgautsch/documo-elixir"

  def project do
    [
      app: :documo_elixir,
      version: "0.1.0",
      elixir: "~> 1.7",
      description: "A client lib for Documo's API.",
      package: package(),
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      name: @name,
      source_url: @repo_url,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:bypass, "~> 2.0", only: :test},
      {:excoveralls, "~> 0.13.1", only: :test}
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url}
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      source_url: @repo_url,
      main: @name
    ]
  end
end
