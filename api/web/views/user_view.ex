defmodule Mirror.UserView do
  use Mirror.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Mirror.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Mirror.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
    	"type": "user",
    	"id": user.id,
    	"attributes": %{
        "username": user.username,
    		"email": user.email
    	},
      "relationships": %{
        "teams": %{
          "links": %{
            "self": "/api/teams/"
          },
          "data": render_many(user.teams, Mirror.UserView, "team.json", as: :team)
      	},
        "retrospectives": %{
          "links": %{
            "self": "/api/retrospectives/"
          },
          "data": []
        },
        "organizations": %{
          "links": %{
            "self": "/api/organizations/"
          },
          "data": render_many(user.organizations, Mirror.UserView, "organization.json", as: :organization)
        }
      }
    }
  end

  def render("team.json", %{team: team}) do
    %{
      "type": "team",
      "id": team.uuid
    }
  end

  def render("organization.json", %{organization: organization}) do
    %{
      "type": "organization",
      "id": organization.uuid
    }
  end
end
