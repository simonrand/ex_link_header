defmodule ExLinkHeader do

  @moduledoc """
  HTTP link header parser and builder
  """

  #
  # Use RFC5988 Registered Relations Types
  #
  defstruct alternate: nil,
    appendix: nil,
    bookmark: nil,
    chapter: nil,
    contents: nil,
    copyright: nil,
    current: nil,
    describedby: nil,
    edit: nil,
    edit_media: nil,
    enclosure: nil,
    first: nil,
    glossary: nil,
    help: nil,
    hub: nil,
    index: nil,
    last: nil,
    latest_version: nil,
    license: nil,
    next_archive: nil,
    next: nil,
    payment: nil,
    predecessor_version: nil,
    prev_archive: nil,
    prev: nil,
    previous: nil,
    related: nil,
    replies: nil,
    section: nil,
    self: nil,
    service: nil,
    start: nil,
    stylesheet: nil,
    subsection: nil,
    successor_version: nil,
    up: nil,
    version_history: nil,
    via: nil,
    working_copy: nil,
    working_copy_of: nil

  defmodule ParseError do
    @moduledoc """
    HTTP link header parse error
    """

    defexception [:message]

    def exception(msg), do: %__MODULE__{message: msg}
  end

  defmodule BuildError do
    @moduledoc """
    HTTP link header build error
    """

    defexception [:message]

    def exception(msg), do: %__MODULE__{message: msg}
  end

  def parse(header, defaults \\ %{}) do
    ExLinkHeader.Parser.parse(header, defaults)
  end

  def parse!(header, defaults \\ %{}) do
    ExLinkHeader.Parser.parse!(header, defaults)
  end

  def build(h) do
    ExLinkHeader.Builder.build(h)
  end

end
