defmodule MirrorWeb.RetrospectiveSerializer do
  use JaSerializer

  def id(retrospective, _conn), do: retrospective.id
  def type, do: "retrospective"
end