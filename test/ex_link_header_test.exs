defmodule ExLinkHeaderTest do
  use ExUnit.Case
  doctest ExLinkHeader

  require ExLinkHeader

  test "parsing a header with next and last links and different order params" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next\", " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=\"last\""

    links = ExLinkHeader.parse(link_header)

    assert links ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
          page: "3",
          per_page: "100"
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
          per_page: nil
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
          per_page: "100"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
          page: "3",
          per_page: "100"
        }
      }
  end

  test "parsing an empty link header" do
    link_header = ""

    links = ExLinkHeader.parse(link_header)

    assert links == %{}
  end


end
