# ExLinkHeader

Parse HTTP link headers in Elixir.

Goal is to implement all in section 5 of http://tools.ietf.org/id/draft-nottingham-http-link-header-06.txt,
however this is currently lacking support for:

- multiple values within the `rel` link-param

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
