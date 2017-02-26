defmodule Mirror.RetrospectiveView do
  use Mirror.Web, :view

  def render("index.json", %{retrospectives: retrospectives}) do
    %{data: render_many(retrospectives, Mirror.RetrospectiveView, "retrospective.json")}
  end

  def render("show.json", %{retrospective: retrospective}) do
    %{data: render_one(retrospective, Mirror.RetrospectiveView, "retrospective.json")}
  end

  def render("delete.json", _) do
    %{
      meta: %{}
    }
  end

  def render("retrospective.json", %{retrospective: retrospective}) do
    %{
    	"type": "retrospective",
    	"id": retrospective.id,
    	"attributes": %{
        "name": retrospective.name,
        "is-anonymous": retrospective.isAnonymous,
        "state": retrospective.state,
        "cancelled": retrospective.cancelled
    	},
      "relationships": %{
        "moderator": %{
          "links": %{
            "self": "/api/users/"
          },
          "data": render_one(retrospective.moderator, Mirror.UserView, "relationship.json", as: :user)
      	},
        "participants": %{
          "links": %{
            "self": "/api/users/"
          },
          "data": render_many(retrospective.participants, Mirror.UserView, "relationship.json", as: :user)
        },
        "team": %{
          "links": %{
            "self": "/api/teams/"
          },
          "data": render_one(retrospective.team, Mirror.TeamView, "relationship.json", as: :team)
        },
        "scores": %{
          "links": %{
            "self": "/api/scores/"
          },
          "data": render_many(retrospective.scores, Mirror.SprintScoreView, "relationship.json", as: :score)
        },
        "feedbacks": %{
          "links": %{
            "self": "/api/feedbacks/"
          },
          "data": render_many(retrospective.feedbacks, Mirror.FeedbackView, "relationship.json", as: :feedback)
        }
      }
    }
  end

  def render("relationship.json", %{retrospective: retrospective}) do
    %{
      "type": "retrospective",
      "id": retrospective.id
    }
  end
end
