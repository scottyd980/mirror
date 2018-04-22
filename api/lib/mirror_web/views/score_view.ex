defmodule MirrorWeb.ScoreView do
  use MirrorWeb, :view
  alias MirrorWeb.ScoreView

  def render("index.json", %{scores: scores}) do
    %{data: render_many(scores, ScoreView, "score.json")}
  end

  def render("show.json", %{score: score}) do
    %{data: render_one(score, ScoreView, "score.json")}
  end

  def render("score.json", %{score: score}) do
    %{id: score.id,
      score: score.score}
  end
end
