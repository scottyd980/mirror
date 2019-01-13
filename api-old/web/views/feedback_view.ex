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
            "user": get_user(feedback),
            "retrospective": %{
                "links": %{
                    "self": "/api/retrospectives/"
                },
                "data": render_one(feedback.retrospective, Mirror.RetrospectiveView, "relationship.json", as: :retrospective)
            },
            "action": %{
                "links": %{
                    "self": "/api/actions/"
                },
                "data": render_one(List.first(feedback.actions), Mirror.ActionView, "relationship.json", as: :action)
            }
        }
    }
  end

  def render("relationship.json", %{feedback: feedback}) do
    %{
      "type": "feedback",
      "id": feedback.id
    }
  end

  defp get_user(feedback) do
    case feedback.retrospective.isAnonymous do
        true -> %{
            "links": %{
                "self": "/api/users/"
            },
            "data": render_one(feedback.user, Mirror.UserView, "relationship.json", as: :user)
        }
        _ -> 
            %{
                "links": %{
                    "self": "/api/users/"
                },
                "data": render_one(feedback.user, Mirror.UserView, "relationship.json", as: :user)
            }
    end
  end
end
