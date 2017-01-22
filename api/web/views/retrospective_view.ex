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
        },
        "scores": %{
          "links": %{
            "self": "/api/scores/"
          },
          "data": render_many(retrospective.scores, Mirror.RetrospectiveView, "score.json", as: :score)
        },
        "feedbacks": %{
          "links": %{
            "self": "/api/feedbacks/"
          },
          "data": render_many(retrospective.feedbacks, Mirror.RetrospectiveView, "feedback.json", as: :feedback)
        }
      }
    }
  end

  def render("user.json", %{user: user}) do
    %{
      "type": "users",
      "id": user.id
    }
  end

  def render("team.json", %{team: team}) do
    %{
      "type": "teams",
      "id": team.id
    }
  end

  def render("score.json", %{score: score}) do
    %{
      "type": "scores",
      "id": score.id
    }
  end

  def render("feedback.json", %{feedback: feedback}) do
    %{
      "type": "feedbacks",
      "id": feedback.id
    }
  end
end
