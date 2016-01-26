defmodule ExLinkHeader do

  @moduledoc """
  HTTP link header parser
  """

  @regex_format ~r{<?(.+)>; (.+)}

  defmodule ParseError do
    defexception [:message]

    def exception(msg), do: %__MODULE__{message: msg}
  end

  def parse(""), do: :error
  def parse(nil), do: :error
  def parse(link_header), do: parse_links(link_header)

  def parse!(link_header) do
    case parse(link_header) do
      {:ok, result} -> result
      :error -> raise ParseError, "Parse error: no valid links to parse"
    end
  end

  defp extract(links) do
    Enum.filter_map(links, fn(link) ->
      Regex.match?(@regex_format, link)
    end, fn(link) ->
      [_, url, params] = Regex.run(@regex_format, link)
      {url, parse_params(params)}
    end)
  end

  defp extract_relationships(links) when links == [], do: nil
  defp extract_relationships(links) do
    links
    |> Enum.flat_map(fn(link) ->
        {url, params} = link
        %{rel: rels} = params

        rels
        |> String.split(" ", trim: true)
        |> Enum.map(fn(rel) ->
            {url, Map.merge(params, %{rel: rel})}
          end)
      end)
  end

  defp filter(nil), do: nil
  defp filter(links) do
    Enum.filter(links, fn(link) ->
      {url, params} = link
      valid_url?(url) && has_rel?(params)
    end)
  end

  defp format(nil), do: parse(nil)
  defp format(links) do
    formatted_links = links
      |> Enum.map(fn(link) ->
          {url, params} = link

          %{rel: rel} = params

          page = case Regex.run(~r{.+[\?|\&]page=(\d+)\??}, url) do
            [_, page] -> page
            nil -> nil
          end

          per_page = case Regex.run(~r{.+[\?|\&]per_page=(\d+)\??}, url) do
            [_, per_page] -> per_page
            nil -> nil
          end

          {rel, Map.merge(%{page: page, per_page: per_page, url: url}, params)}
        end)
      |> Enum.into(%{})

    {:ok, formatted_links}
  end

  defp has_rel?(params) do
    Map.has_key?(params, :rel)
  end

  defp parse_links(links) do
    links
    |> String.split(~r{,\s*<}, trim: true)
    |> extract
    |> filter
    |> extract_relationships
    |> format
  end

  defp parse_params(params) do
    params
    |> String.split(";", trim: true)
    |> Enum.map(fn(param) ->
        [_, name, value] = Regex.run(~r{(\w+)=\"?([\w\s]+)\"?}, param)
        {String.to_atom(name), value}
      end)
    |> Enum.into(%{})
  end

  defp valid_url?(url) do
    case URI.parse(url) do
      %URI{host: nil} -> false
      %URI{scheme: nil} -> false
      %URI{path: nil} -> false
      _ -> true
    end
  end

end
