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
          "data": render_many(user.teams, Mirror.TeamView, "relationship.json", as: :team)
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
          "data": render_many(user.organizations, Mirror.OrganizationView, "relationship.json", as: :organization)
        }
      }
    }
  end

  def render("relationship.json", %{user: user}) do
    %{
      "type": "user",
      "id": user.id
    }
  end
  
end
