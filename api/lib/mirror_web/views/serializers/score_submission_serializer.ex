defmodule MirrorWeb.ScoreSubmissionSerializer do
  use JaSerializer

  def id(submission, _conn), do: submission.id
  def type, do: "score-submission"
end