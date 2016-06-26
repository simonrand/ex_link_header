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

  defp dobuild(%ExLinkHeaderEntry{host: nil} = _h, _relation) do
  end

  defp dobuild(%ExLinkHeaderEntry{host: ""} = _h, _relation) do
  end

  defp dobuild(%ExLinkHeaderEntry{} = h, relation) do
    q = concatenate(h.q_params, "&", false)

    scheme = case h.scheme do
      v when is_atom(v) -> Atom.to_string(v)
      v when is_binary(v) -> v
      _ -> raise BuildError, "Invalid scheme format/type"
    end
    h = Map.put(h, :scheme, scheme)

    url = case h.path do
      "" -> h.scheme <> "://" <> h.host
      p when is_binary(p) -> h.scheme <> "://" <> h.host <> "/" <> h.path
      :nil -> h.scheme <> h.host
      _ -> h.scheme <> h.host
    end

    url = case q do
      "" -> url
      v when is_binary(v) -> url <> "?" <> v
      _ -> url
    end

    attrs = case concatenate(h.t_attributes, "; ", true) do
      "" -> ""
      v when is_binary(v) -> "; " <> v
      _ -> ""
    end

    "<" <> url <> ">; rel=\"" <> Atom.to_string(relation) <> "\"" <> attrs
  end

  defp dobuild(_any, _whatever) do
  end

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
