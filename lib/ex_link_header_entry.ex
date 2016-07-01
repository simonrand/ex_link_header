defmodule ExLinkHeaderEntry do

  @moduledoc """
  Parsed HTTP link header entry
  """

  defstruct attributes: %{},
    host: "",
    params: %{},
    path: "",
    scheme: "http",
    url: :nil

end
