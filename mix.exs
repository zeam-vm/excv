defmodule Excv.MixProject do
  use Mix.Project

  @source_url "https://github.com/zeam-vm/excv"
  @version "0.1.0-dev"

  def project do
    [
      app: :excv,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_clean: ["clean"],
      package: package()
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
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:git_hooks, "~> 0.6.4", only: [:dev], runtime: false},
      {:elixir_make, "~> 0.6", runtime: false},
      {:nx, "~> 0.1.0-dev", github: "elixir-nx/nx", branch: "main", sparse: "nx"}
    ]
  end

  def docs do
    [
      main: "Excv",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp package do
    [
      links: %{
        "GitHub" => @source_url
      },
      licenses: ["Apache-2.0"],
      source_url: @source_url,
      files: [
        "lib",
        "LICENSE",
        "mix.exs",
        "README.md",
        "c_src",
        "Makefile"
      ]
    ]
  end
end
