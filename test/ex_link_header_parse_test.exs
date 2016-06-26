defmodule ExLinkHeaderParseTest do
  use ExUnit.Case
  doctest ExLinkHeader

  alias ExLinkHeader.ParseError
  require ExLinkHeader

  test "parsing a header with next and last links, different order url params and different spacing between links" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next\", " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=\"last\"," <>
      "<https://api.github.com/user/simonrand/repos?page=1&per_page=100>; rel=\"first\""

    parsed = ExLinkHeader.parse!(link_header)
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :next) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "2", per_page: "100"}
    }
    assert Map.get(parsed, :last) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "3", per_page: "100"}
    }
    assert Map.get(parsed, :first) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?page=1&per_page=100",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "1", per_page: "100"}
    }
  end

  test "parsing a header with extra params and different param spacing" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next\";ler=\"page\""

    parsed = ExLinkHeader.parse!(link_header)
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :next) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "2", per_page: "100"},
      t_attributes: %{ler: "page"}
    }
  end

  test "parsing a header with multiple rel values and spaces" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next last\"; ler=\"page\", " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=\"prev first \""

    parsed = ExLinkHeader.parse!(link_header)
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :next) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "2", per_page: "100"},
      t_attributes: %{ler: "page"}
    }
    assert Map.get(parsed, :last) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "2", per_page: "100"},
      t_attributes: %{ler: "page"}
    }
    assert Map.get(parsed, :prev) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "3", per_page: "100"}
    }
    assert Map.get(parsed, :first) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "3", per_page: "100"}
    }
  end

  test "parsing a header with next and last and no space between links and no default values" do
    link_header =
      "<https://api.github.com/user/simonrand/repos>; rel=\"next\"," <>
      "<https://api.github.com/user/simonrand/repos>; rel=\"last\""

    parsed = ExLinkHeader.parse!(link_header)
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :next) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
    }
    assert Map.get(parsed, :last) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
    }
  end

  test "parsing a header with unquoted relationships" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=next, " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=last"

    parsed = ExLinkHeader.parse!(link_header)
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :next) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "2", per_page: "100"}
    }
    assert Map.get(parsed, :last) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "3", per_page: "100"}
    }
  end

  test "parsing a header with next and last links and only some url params" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100>; rel=\"next\", " <>
      "<https://api.github.com/user/simonrand/repos?page=3>; rel=\"last\""

    parsed = ExLinkHeader.parse!(link_header)
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :next) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?per_page=100",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{per_page: "100"}
    }
    assert Map.get(parsed, :last) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?page=3",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "3"}
    }
  end

  test "parsing a header with an invalid url and a default for value page" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100>; rel=\"next\", " <>
      "<https//api.github.com/user/simonrand/repos?page=3>; rel=\"last\""

    parsed = ExLinkHeader.parse!(link_header, %{page: nil})
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :next) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?per_page=100",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: nil, per_page: "100"}
    }
  end

  test "parsing a header including a link without a relationship param" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=next, " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; ler=last"

    parsed = ExLinkHeader.parse!(link_header)
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :next) == %ExLinkHeaderEntry{
      url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
      scheme: "https",
      host: "api.github.com",
      path: "/user/simonrand/repos",
      q_params: %{page: "2", per_page: "100"}
    }

    assert Map.get(parsed, :ler) == nil
  end

  test "parsing a header with a comma in a link and default values" do
    link_header =
      "<https://api.github.com/search/repositories?q=elixir,ruby&sort=stars&order=desc>; rel=\"last\""

    parsed = ExLinkHeader.parse!(link_header, %{page: nil, per_page: nil})
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :last) == %ExLinkHeaderEntry{
      url: "https://api.github.com/search/repositories?q=elixir,ruby&sort=stars&order=desc",
      scheme: "https",
      host: "api.github.com",
      path: "/search/repositories",
      q_params: %{page: nil, per_page: nil, q: "elixir,ruby", sort: "stars", order: "desc"}
    }
  end

  test "parsing a header with arbitrary params and no defaults" do
    link_header =
      "<https://api.example.com/?q=elixir&sort=stars&order=desc>; rel=\"last\""

    parsed = ExLinkHeader.parse!(link_header)
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :last) == %ExLinkHeaderEntry{
      url: "https://api.example.com/?q=elixir&sort=stars&order=desc",
      scheme: "https",
      host: "api.example.com",
      path: "/",
      q_params: %{q: "elixir", sort: "stars", order: "desc"}
    }

  end

  test "parsing a header with no path, arbitrary params and no defaults" do
    link_header =
      "<https://api.example.com?q=elixir&sort=stars&order=desc>; rel=\"last\""

    parsed = ExLinkHeader.parse!(link_header)
    assert %ExLinkHeader{} = parsed
    assert Map.get(parsed, :last) == %ExLinkHeaderEntry{
      url: "https://api.example.com?q=elixir&sort=stars&order=desc",
      scheme: "https",
      host: "api.example.com",
      path: nil,
      q_params: %{q: "elixir", sort: "stars", order: "desc"}
    }
  end

  test "parsing an empty or invalid link header raises" do
    assert_raise ParseError, fn -> ExLinkHeader.parse!("") end
    assert_raise ParseError, fn -> ExLinkHeader.parse!("nonsense") end
  end

end
