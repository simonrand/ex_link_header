defmodule ExLinkHeaderBuildTest do
  use ExUnit.Case

  alias ExLinkHeader.BuildError
  require ExLinkHeader

  test "build raises if wrong query params are passed" do
    link = %ExLinkHeader{
      next: %ExLinkHeaderEntry{host: "www.example.com",
        params: %{q: 'elixir'}
      }
    }
    assert_raise BuildError, fn -> ExLinkHeader.build(link) end
  end

  test "build a simple link with scheme as atom" do
    rel = "next"
    host = "www.example.com"

    link = %ExLinkHeader{
      next: %ExLinkHeaderEntry{
        host: host,
        scheme: :https
      }
    }
    link_h = ExLinkHeader.build(link)

    assert link_h == "<https://" <> host <> ">; rel=\"" <> rel <> "\""
  end

  test "build a simple link" do
    rel = "next"
    host = "www.example.com"

    link = %ExLinkHeader{
      next: %ExLinkHeaderEntry{host: host}
    }
    link_h = ExLinkHeader.build(link)

    assert link_h == "<http://" <> host <> ">; rel=\"" <> rel <> "\""
  end

  test "build a simple link with additional params" do
    rel = "next"
    host = "www.example.com"

    link = %ExLinkHeader{
      next: %ExLinkHeaderEntry{host: host,
        attributes: %{hreflang: "en", title: "mytitle"}
      }
    }
    link_h = ExLinkHeader.build(link)

    assert link_h == "<http://" <> host <> ">; rel=\"" <> rel <> "\"; hreflang=\"en\"; title=\"mytitle\""
  end

  test "build a link with query params" do
    rel = "next"
    host = "www.example.com"

    link = %ExLinkHeader{
      next: %ExLinkHeaderEntry{host: host,
        params: %{page: 5, q: "elixir"}
      }
    }
    link_h = ExLinkHeader.build(link)

    # this assertion may fail, since Maps are not ordered.
    # need to find a way to better check without relying on
    # ordering

    assert link_h == "<http://" <> host <> "?page=5&q=elixir>; rel=\"" <> rel <> "\""
  end

  test "build some simple links" do
    rel_a = "next"
    rel_b = "prev"
    host = "www.example.com"

    link = %ExLinkHeader{
      next: %ExLinkHeaderEntry{host: host},
      prev: %ExLinkHeaderEntry{host: host}
    }

    link_h = ExLinkHeader.build(link)
    #
    # relations will appear in reversed alphabetical order
    #
    assert link_h == "<http://" <> host <> ">; rel=\"" <> rel_b <> "\", " <>
      "<http://" <> host <> ">; rel=\"" <> rel_a <> "\""
  end

end
