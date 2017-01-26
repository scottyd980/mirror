defmodule Mirror.FeedbackView do
  use Mirror.Web, :view

  def render("index.json", %{feedback: feedback}) do
    %{data: render_many(feedback, Mirror.FeedbackView, "feedback.json")}
  end

  def render("show.json", %{feedback: feedback}) do
      %{data: render_one(feedback, Mirror.FeedbackView, "feedback.json")}
  end

  def render("delete.json", %{feedback: feedback}) do
    %{meta: %{}}
  end

  def render("feedback.json", %{feedback: feedback}) do
    %{
        "type": "feedbacks",
        "id": feedback.id,
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
                "data": render_one(feedback.retrospective_id, Mirror.FeedbackView, "retrospective.json", as: :retrospective)
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
