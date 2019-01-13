defmodule MirrorWeb.UserSerializer do
  use JaSerializer

  def id(user, _conn), do: user.id
  def type, do: "user"
end