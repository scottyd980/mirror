defmodule Mirror.UserTeamView do
  use Mirror.Web, :view

  def render("index.json", %{user_teams: user_teams}) do
    %{data: render_many(user_teams, Mirror.UserTeamView, "user_team.json")}
  end

  def render("show.json", %{user_team: user_team}) do
    %{data: render_one(user_team, Mirror.UserTeamView, "user_team.json")}
  end

  def render("user_team.json", %{user_team: user_team}) do
    %{
    	"type": "user_team",
      "attributes": %{
      	"team_id": user_team.team_id,
        "user_id": user_team.user_id
    	}
    }
  end
end
