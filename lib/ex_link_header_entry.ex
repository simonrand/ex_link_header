defmodule ExLinkHeaderEntry do

  defstruct url: :nil,
    scheme: "http",
    host: "",
    path: "",
    q_params: %{},
    t_attributes: %{}

end
