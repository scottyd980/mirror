defmodule MirrorWeb.ActionSerializer do
  use JaSerializer

  def id(action, _conn), do: action.id
  def type, do: "action"
end