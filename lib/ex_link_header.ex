defmodule ExLinkHeader do

  @moduledoc """
  HTTP link header parser
  """

  def parse("") do
    %{}
  end

  def parse(nil) do
    %{}
  end

  def parse(link_header) do
    links = String.split(link_header, ", ")

    parse_links(links)
  end

  defp is_rel?(name) do
    name == "rel"
  end

  defp parse_links(links) do
    parsed_links = Enum.filter_map(links, fn link ->
      [_, url, param] = Regex.run(~r{<([^>]+)>; (\w+)="?[a-z]+"?.+}, link)

      valid_url?(url) && is_rel?(param)
    end, fn link ->
        [_, url, name] = Regex.run(~r{<([^>]+)>; \w+="?([a-z]+)"?}, link)

        page = case Regex.run(~r{.+[\?|\&]page=(\d+)\??}, url) do
          [_, page] -> page
          nil -> nil
        end

        per_page = case Regex.run(~r{.+[\?|\&]per_page=(\d+)\??}, url) do
          [_, per_page] -> per_page
          nil -> nil
        end

        {name, %{ url: url, page: page, per_page: per_page, rel: name }}
      end
    )

    parsed_links
    |> Enum.into(%{})
  end

  defp valid_url?(url) do
    case URI.parse(url) do
      %URI{host: nil} -> false
      %URI{scheme: nil} -> false
      %URI{path: nil} -> false
      uri -> true
    end
  end

end
