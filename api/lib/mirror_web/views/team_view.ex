defmodule MirrorWeb.TeamView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView

  require Logger

  attributes [:name, :avatar, :uuid, :is_anonymous]

  def id(struct, conn) do
    struct.uuid
  end

  def render("next_sprint.json-api", %{next_sprint: next_sprint, team: team}) do
    %{
      "id": team.uuid,
      "next_sprint": next_sprint
    }
  end
end
