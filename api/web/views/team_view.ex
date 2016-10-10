defmodule Mirror.TeamView do
  use Mirror.Web, :view

  import Logger

  def render("index.json", %{teams: teams}) do
    %{data: render_many(teams, Mirror.TeamView, "team.json")}
  end

  def render("show.json", %{team: team}) do
    %{data: render_one(team, Mirror.TeamView, "team.json")}
  end

  def render("team.json", %{team: team}) do
    # Logger.info team
    %{
    	"type": "team",
    	"id": team.id,
    	"attributes": %{
        "name": team.name,
        "isAnonymous": team.isAnonymous,
        "avatar": team.avatar
    	},
      "relationships": %{
        "admin": %{
          "links": %{
            "self": "/api/users/#{team.admin.id}"
          },
          "data": %{
            "type": "user",
            "id": team.admin.id
          }
      	}
      }
    }
  end
end
