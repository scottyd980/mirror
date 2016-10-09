defmodule Mirror.TeamView do
  use Mirror.Web, :view

  def render("index.json", %{teams: teams}) do
    %{data: render_many(teams, Mirror.TeamView, "team.json")}
  end

  def render("show.json", %{team: team}) do
    %{data: render_one(team, Mirror.TeamView, "team.json")}
  end

  def render("team.json", %{team: team}) do
    %{id: team.id,
      name: team.name,
      isAnonymous: team.isAnonymous,
      avatar: team.avatar,
      admin: team.admin}
  end
end
