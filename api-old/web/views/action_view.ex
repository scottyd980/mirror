defmodule Mirror.ActionView do
  use Mirror.Web, :view

  def render("index.json", %{action: action}) do
    %{data: render_many(action, Mirror.ActionView, "action.json")}
  end

  def render("show.json", %{action: action}) do
      %{data: render_one(action, Mirror.ActionView, "action.json")}
  end

  def render("delete.json", %{action: action}) do
    %{meta: %{}}
  end

  def render("action.json", %{action: action}) do
    %{
        "type": "actions",
        "id": action.id,
        "attributes": %{
            "message": action.message,
        },
        "relationships": %{
            "feedback": %{
                "links": %{
                    "self": "/api/feedbacks/"
                },
                "data": render_one(action.feedback, Mirror.FeedbackView, "relationship.json", as: :feedback)
            }
        }
    }
  end

  def render("relationship.json", %{action: action}) do
    %{
      "type": "action",
      "id": action.id
    }
  end
end
