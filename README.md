# ExLinkHeader

Parse HTTP link headers in Elixir.

# Usage

```elixir
ExLinkHeader.parse("<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next\", <https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=\"last\", <https://api.github.com/user/simonrand/repos?page=1&per_page=100>; rel=\"first\"")
#=> %{"first" => %{page: "1", per_page: "100", rel: "first", url: "https://api.github.com/user/simonrand/repos?page=1&per_page=100"}, "last" => %{page: "3", per_page: "100", rel: "last", url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100"}, "next" => %{page: "2", per_page: "100", rel: "next", url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2"} }
```

## Code Status

[![Build Status](https://travis-ci.org/simonrand/ex_link_header.svg?branch=master)](https://travis-ci.org/simonrand/ex_link_header)

## Installation

The package can be installed as:

  1. Add ex_link_header to your list of dependencies in `mix.exs`:

        def deps do
          [{:ex_link_header, "~> 0.0.2"}]
        end

  2. Ensure ex_link_header is started before your application:

        def application do
          [applications: [:ex_link_header]]
        end

## License

Released under the Apache 2 License.

See [LICENSE](LICENSE) for more information.
