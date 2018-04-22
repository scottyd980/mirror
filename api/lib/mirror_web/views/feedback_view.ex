defmodule MirrorWeb.FeedbackView do
  use MirrorWeb, :view
  alias MirrorWeb.FeedbackView

  def render("index.json", %{feedbacks: feedbacks}) do
    %{data: render_many(feedbacks, FeedbackView, "feedback.json")}
  end

  def render("show.json", %{feedback: feedback}) do
    %{data: render_one(feedback, FeedbackView, "feedback.json")}
  end

  def render("feedback.json", %{feedback: feedback}) do
    %{id: feedback.id,
      category: feedback.category,
      message: feedback.message,
      state: feedback.state}
  end
end
