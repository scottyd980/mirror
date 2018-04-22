defmodule MirrorWeb.FeedbackSerializer do
  use JaSerializer

  def id(feedback, _conn), do: feedback.id
  def type, do: "feedback"
end