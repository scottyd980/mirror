defmodule MirrorWeb.TeamSerializer do
  use JaSerializer

  def id(team, _conn), do: team.uuid
  def type, do: "team"
end