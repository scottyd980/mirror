defmodule Mirror.TeamView do
  use Mirror.Web, :view

  def render("index.json", %{teams: teams}) do
    %{data: render_many(teams, Mirror.TeamView, "team.json")}
  end

  def render("show.json", %{team: team}) do
    %{data: render_one(team, Mirror.TeamView, "team.json")}
  end

  def render("team.json", %{team: team}) do
    %{
    	"type": "team",
    	"id": team.uuid,
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
          "data": render_many(team.admins, Mirror.UserView, "relationship.json", as: :user)
      	},
        "members": %{
          "links": %{
            "self": "/api/users/"
          },
          "data": render_many(team.members, Mirror.UserView, "relationship.json", as: :user)
        },
        "organization": %{
          "links": %{
            "self": "/api/organizations/"
          },
          "data": render_one(team.organization, Mirror.OrganizationView, "relationship.json", as: :organization)
        }
      }
    }
  end

  def render("next_sprint.json", %{next_sprint: next_sprint, team: team}) do
    %{
      "id": team.uuid,
      "next_sprint": next_sprint
    }
  end

  def render("relationship.json", %{team: team}) do
    %{
      "type": "team",
      "id": team.uuid
    }
  end
end
