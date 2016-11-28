defmodule Mirror.RetrospectiveView do
  use Mirror.Web, :view

  import Logger

  def render("index.json", %{retrospectives: retrospectives}) do
    %{data: render_many(retrospectives, Mirror.RetrospectiveView, "retrospective.json")}
  end

  def render("show.json", %{retrospective: retrospective}) do
    %{data: render_one(retrospective, Mirror.RetrospectiveView, "retrospective.json")}
  end

  def render("retrospective.json", %{retrospective: retrospective}) do
    # Logger.info retrospective
    %{
    	"type": "retrospective",
    	"id": retrospective.id,
    	"attributes": %{
        "name": retrospective.name,
        "is-anonymous": retrospective.isAnonymous,
        "state": retrospective.state
    	},
      "relationships": %{
        "moderator": %{
          "links": %{
            "self": "/api/users/"
          },
          "data": render_one(retrospective.moderator, Mirror.RetrospectiveView, "user.json", as: :user)
      	},
        "participants": %{
          "links": %{
            "self": "/api/users/"
          },
          "data": render_many(retrospective.participants, Mirror.RetrospectiveView, "user.json", as: :user)
        },
        "team": %{
          "links": %{
            "self": "/api/teams/"
          },
          "data": render_one(retrospective.team, Mirror.RetrospectiveView, "team.json", as: :team)
        }
      }
    }
  end

  def render("user.json", %{user: user}) do
    %{
      "type": "user",
      "id": user.id
    }
  end

  def render("team.json", %{team: team}) do
    %{
      "type": "team",
      "id": team.id
    }
  end
end
