defmodule ExLinkHeader.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_link_header,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
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
      {:credo, "~> 0.2", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    Parse HTTP link headers in Elixir.
    """
  end

  defp package do
      [# These are the default files included in the package
       maintainers: ["Simon Rand"],
       licenses: ["Apache 2.0"],
       links: %{"GitHub" => "https://github.com/simonrand/ex_link_header"}]
    end
end
