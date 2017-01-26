defmodule Mirror.FeedbackView do
  use Mirror.Web, :view

  def render("index.json", %{feedback: feedback}) do
    %{data: render_many(score, Mirror.FeedbackView, "score.json")}
  end

  def render("show.json", %{feedback: feedback}) do
      %{data: render_one(score, Mirror.FeedbackView, "score.json")}
  end

  def render("delete.json", %{feedback: feedback}) do
    %{meta: %{}}
  end

  def render("score.json", %{feedback: feedback}) do
    %{
        "type": "scores",
        "id": score.id,
        "attributes": %{
            "message": feedback.message,
            "state": feedback.state,
            "type": feedback.type
        },
        "relationships": %{
            "user": %{
                "links": %{
                    "self": "/api/users/"
                },
                "data": render_one(feedback.user_id, Mirror.FeedbackView, "user.json", as: :user)
            },
            "retrospective": %{
                "links": %{
                    "self": "/api/retrospectives/"
                },
                "data": render_one(score.retrospective_id, Mirror.FeedbackView, "retrospective.json", as: :retrospective)
            }
        }
    }
  end

  def render("user.json", %{user: user}) do
    %{
      "type": "users",
      "id": user
    }
  end

  def render("retrospective.json", %{retrospective: retrospective}) do
    %{
      "type": "retrospectives",
      "id": retrospective
    }
  end
end
