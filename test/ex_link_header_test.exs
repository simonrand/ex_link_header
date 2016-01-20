defmodule ExLinkHeaderTest do
  use ExUnit.Case
  doctest ExLinkHeader

  require ExLinkHeader

  test "parsing a header with next and last links, different order url params and different spacing between links" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next\", " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=\"last\"," <>
      "<https://api.github.com/user/simonrand/repos?page=1&per_page=100>; rel=\"first\""

    links = ExLinkHeader.parse(link_header)

    assert links ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "next"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
          page: "3",
          per_page: "100",
          rel: "last"
        },
        "first" => %{
          url: "https://api.github.com/user/simonrand/repos?page=1&per_page=100",
          page: "1",
          per_page: "100",
          rel: "first"
        }
      }
  end

  test "parsing a header with extra params and different param spacing" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next\";ler=\"page\""

    links = ExLinkHeader.parse(link_header)

    assert links ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "next",
          ler: "page"
        }
      }
  end

  test "parsing a header with multiple rel values and spaces" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next last\"; ler=\"page\", " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=\"prev first \""

    links = ExLinkHeader.parse(link_header)

    assert links ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "next",
          ler: "page"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "last",
          ler: "page"
        },
        "prev" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
          page: "3",
          per_page: "100",
          rel: "prev"
        },
        "first" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
          page: "3",
          per_page: "100",
          rel: "first"
        }
      }
  end

  test "parsing a header with next and last and no space between links" do
    link_header =
      "<https://api.github.com/user/simonrand/repos>; rel=\"next\"," <>
      "<https://api.github.com/user/simonrand/repos>; rel=\"last\""

    links = ExLinkHeader.parse(link_header)

    assert links ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos",
          page: nil,
          per_page: nil,
          rel: "next"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos",
          page: nil,
          per_page: nil,
          rel: "last"
        }
      }
  end

  test "parsing a header with unquoted relationships" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=next, " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=last"

    links = ExLinkHeader.parse(link_header)

    assert links ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "next"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
          page: "3",
          per_page: "100",
          rel: "last"
        }
      }
  end

  test "parsing a header with next and last links and only some url params" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100>; rel=\"next\", " <>
      "<https://api.github.com/user/simonrand/repos?page=3>; rel=\"last\""

    links = ExLinkHeader.parse(link_header)

    assert links ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100",
          page: nil,
          per_page: "100",
          rel: "next"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3",
          page: "3",
          per_page: nil,
          rel: "last"
        }
      }
  end


  test "parsing a header with an invalid url" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100>; rel=\"next\", " <>
      "<https//api.github.com/user/simonrand/repos?page=3>; rel=\"last\""

    links = ExLinkHeader.parse(link_header)

    assert links ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100",
          page: nil,
          per_page: "100",
          rel: "next"
        }
      }
  end

  test "parsing a header including a link without a relationship param" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=next, " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; ler=last"

    links = ExLinkHeader.parse(link_header)

    assert links ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "next"
        }
      }
  end

  test "parsing a header with a comma in a link" do
    link_header =
      "<https://api.github.com/search/repositories?q=elixir,ruby&sort=stars&order=desc>; rel=\"last\""

    links = ExLinkHeader.parse(link_header)

    assert links ==
      %{"last" => %{
          url: "https://api.github.com/search/repositories?q=elixir,ruby&sort=stars&order=desc",
          page: nil,
          per_page: nil,
          rel: "last"
        }
      }
  end

  test "parsing an empty link header" do
    link_header = ""

    links = ExLinkHeader.parse(link_header)

    assert links == %{}
  end

  test "parsing nonsense" do
    link_header = "nonsense"

    links = ExLinkHeader.parse(link_header)

    assert links == %{}
  end


end
