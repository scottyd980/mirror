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
        "type": "score",
        "attributes": %{
            "score": score.score
        },
        "relationships": %{
            "user": %{
                "links": %{
                    "self": "/api/users/"
                },
                "data": render_one(score.user_id, Mirror.SprintScoreView, "user.json", as: :user)
            },
            "retrospective": %{
                "links": %{
                    "self": "/api/retrospectives/"
                },
                "data": render_one(score.retrospective_id, Mirror.SprintScoreView, "retrospective.json", as: :retrospective)
            }
        }
    }
  end

  def render("user.json", %{user: user}) do
    %{
      "type": "user",
      "id": user
    }
  end

  def render("retrospective.json", %{retrospective: retrospective}) do
    %{
      "type": "retrospective",
      "id": retrospective
    }
  end
end
