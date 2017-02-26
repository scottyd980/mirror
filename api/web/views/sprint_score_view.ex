defmodule Mirror.SprintScoreView do
  use Mirror.Web, :view

  def render("index.json", %{score: score}) do
    %{data: render_many(score, Mirror.SprintScoreView, "score.json")}
  end

  def render("show.json", %{score: score}) do
      %{data: render_one(score, Mirror.SprintScoreView, "score.json")}
  end

  def render("delete.json", %{score: score}) do
    %{meta: %{}}
  end

  def render("score.json", %{sprint_score: score}) do
    %{
        "type": "scores",
        "id": score.id,
        "attributes": %{
            "score": score.score
        },
        "relationships": %{
            "user": %{
                "links": %{
                    "self": "/api/users/"
                },
                "data": render_one(score.user, Mirror.UserView, "relationship.json", as: :user)
            },
            "retrospective": %{
                "links": %{
                    "self": "/api/retrospectives/"
                },
                "data": render_one(score.retrospective, Mirror.RetrospectiveView, "relationship.json", as: :retrospective)
            }
        }
    }
  end

  def render("relationship.json", %{score: score}) do
    %{
      "type": "score",
      "id": score.id
    }
  end
end
