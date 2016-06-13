defmodule ExLinkHeader.Builder do

  alias ExLinkHeader.BuildError

  @moduledoc """
  HTTP link header builder
  """

  def build(%ExLinkHeader{} = h) do
    {_, acc} = Enum.map_reduce(Map.keys(h), [],
      fn(k, acc) ->
        entry = Map.get(h, k)
        case dobuild(entry, k) do
          v when is_binary(v) -> {v, [v | acc]}
          _ -> {nil, acc}
        end
      end
    )
    Enum.join(acc, ", ")
  end

  defp build_attributes(attributes) do
    case concatenate(attributes, "; ", true) do
      "" -> ""
      v when is_binary(v) -> "; " <> v
      _ -> ""
    end
  end

  defp build_scheme(scheme) do
    case scheme do
      v when is_atom(v) -> Atom.to_string(v)
      v when is_binary(v) -> v
      _ -> raise BuildError, "Invalid scheme format/type"
    end
  end

  defp build_url(scheme, host, path, params) do
    q = concatenate(params, "&", false)

    url = case path do
      "" -> scheme <> "://" <> host
      p when is_binary(p) -> scheme <> "://" <> host <> "/" <> path
      :nil -> scheme <> host
      _ -> scheme <> host
    end

    url = case q do
      "" -> url
      v when is_binary(v) -> url <> "?" <> v
      _ -> url
    end

    url
  end

  defp dobuild(%ExLinkHeaderEntry{host: nil} = _h, _relation), do: :error
  defp dobuild(%ExLinkHeaderEntry{host: ""} = _h, _relation), do: :error
  defp dobuild(%ExLinkHeaderEntry{} = h, relation) do
    h = Map.put(h, :scheme, build_scheme(h.scheme))

    url = build_url(h.scheme, h.host, h.path, h.params)

    attributes = build_attributes(h.attributes)

    "<" <> url <> ">; rel=\"" <> Atom.to_string(relation) <> "\"" <> attributes
  end
  defp dobuild(_any, _whatever), do: :error

  defp concatenate(%{} = map , sep, quoted) when is_binary(sep) do
    Enum.map_join(Map.keys(map), sep, fn(key) ->
      # TODO: sanitize me (urlencode stuff ?)
      val = case Map.get(map, key) do
        v when is_integer(v) -> Integer.to_string(v)
        v when is_atom(v) -> Atom.to_string(v)
        v when is_binary(v) -> v
        _ -> raise BuildError, "Invalid query param value"
      end
      val = case quoted do
        true -> "\"" <> val <> "\""
        _ -> val
      end
      Atom.to_string(key) <> "=" <> val
    end)
  end
end
