defmodule MirrorWeb.ScoreSerializer do
  use JaSerializer

  def id(score, _conn), do: score.id
  def type, do: "score"
end