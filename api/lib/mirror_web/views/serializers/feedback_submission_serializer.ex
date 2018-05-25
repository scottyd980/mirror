defmodule MirrorWeb.FeedbackSubmissionSerializer do
  use JaSerializer

  def id(submission, _conn), do: submission.id
  def type, do: "feedback-submission"
end