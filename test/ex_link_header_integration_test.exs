defmodule ExLinkHeaderIntegrationTest do
  use ExUnit.Case

  require ExLinkHeader

  test "build and parse a simple link" do
    host = "www.example.com"

    link = %ExLinkHeader{
      next: %ExLinkHeaderEntry{host: host}
    }
    link_h = ExLinkHeader.build(link) 

    parsed = ExLinkHeader.parse!(link_h)
    assert Map.get(parsed, :next) ==  %ExLinkHeaderEntry{
      url: "http://" <> host,
      scheme: "http",
      host: "www.example.com",
      path: nil
    }
  end

  test "build and parse a link with query params" do
    host = "www.example.com"

    link = %ExLinkHeader{
      next: %ExLinkHeaderEntry{host: host,
        q_params: %{page: 5, q: "elixir"}
      }
    }
    link_h = ExLinkHeader.build(link) 

    # this assertions may fail, since Maps are not ordered.
    # need to find a way to better check without relying on
    # ordering
    parsed = ExLinkHeader.parse!(link_h)
    assert Map.get(parsed, :next) ==  %ExLinkHeaderEntry{
      url: "http://" <> host <> "?page=5&q=elixir",
      scheme: "http",
      host: "www.example.com",
      path: nil,
      q_params: %{page: "5", q: "elixir"}
  }
  end

  test "build and parse some simple links" do
    host = "www.example.com"

    link = %ExLinkHeader{
      next: %ExLinkHeaderEntry{host: host},
      prev: %ExLinkHeaderEntry{host: host}
    }

    link_h = ExLinkHeader.build(link)
    #
    # relations will appear in reversed alphabetical order
    #
    parsed = ExLinkHeader.parse!(link_h)
    assert Map.get(parsed, :next) ==  %ExLinkHeaderEntry{
      url: "http://" <> host,
      scheme: "http",
      host: "www.example.com",
      path: nil
    }
    assert Map.get(parsed, :prev) ==  %ExLinkHeaderEntry{
      url: "http://" <> host,
      scheme: "http",
      host: "www.example.com",
      path: nil
    }
  end

  test "build and parse a simple link with additional params" do
    host = "www.example.com"

    link = %ExLinkHeader{
      next: %ExLinkHeaderEntry{host: host,
        t_attributes: %{hreflang: "en", title: "mytitle"}
      }
    }
    link_h = ExLinkHeader.build(link) 

    parsed = ExLinkHeader.parse!(link_h)
    assert Map.get(parsed, :next) ==  %ExLinkHeaderEntry{
      url: "http://" <> host,
      scheme: "http",
      host: "www.example.com",
      path: nil,
      t_attributes: %{hreflang: "en", title: "mytitle"}
    }
  end
end
