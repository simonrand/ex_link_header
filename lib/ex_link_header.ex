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
    link_header
    |> split
    |> extract
    |> filter
    |> format
  end

  defp extract(links) do
    links
    |> Enum.map(fn link ->
        [_, url, params] = Regex.run(~r{<(.+)>; (.+)}, link)
        {url, parse_params(params)}
      end)
  end

  defp filter(links) do
    links
    |> Enum.filter(fn link ->
        {url, params} = link
        valid_url?(url) && has_rel?(params)
      end)
  end

  defp format(links) do
    links
    |> Enum.map(fn link ->
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
  end

  defp has_rel?(params) do
    params
    |> Map.has_key?(:rel)
  end

  defp parse_params(params) do
    params
    |> String.split("; ")
    |> Enum.map(fn param ->
        [_, name, value] = Regex.run(~r{(\w+)=\"?(\w+)\"?}, param)
        {String.to_atom(name), value}
      end)
    |> Enum.into(%{})
  end

  defp split(links) do
    links
    |> String.split(", ")
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
