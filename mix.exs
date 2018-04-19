defmodule ExLinkHeader.Mixfile do
  use Mix.Project

  @version "0.0.5"

  def project do
    [
      app: :ex_link_header,
      version: @version,
      elixir: "~> 1.2",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.2", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    Parse HTTP link headers in Elixir.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      maintainers: ["Simon Rand"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/simonrand/ex_link_header"}
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "ExLinkHeader",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/ex_link_header",
      source_url: "https://github.com/simonrand/ex_link_header",
      extras: [
        "README.md"
      ]
    ]
  end
end
