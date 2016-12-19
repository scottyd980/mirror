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
        "is-anonymous": team.isAnonymous,
        "avatar": team.avatar
    	},
      "relationships": %{
        "admins": %{
          "links": %{
            "self": "/api/users/"
          },
          "data": render_many(team.admins, Mirror.TeamView, "user.json", as: :user)
      	},
        "members": %{
          "links": %{
            "self": "/api/users/"
          },
          "data": render_many(team.members, Mirror.TeamView, "user.json", as: :user)
        }
      }
    }
  end

  def render("next_sprint.json", %{next_sprint: next_sprint, team: team}) do
    %{
      "id": team.id,
      "next-sprint": next_sprint
    }
  end

  def render("user.json", %{user: user}) do
    %{
      "type": "user",
      "id": user.id
    }
  end
end
