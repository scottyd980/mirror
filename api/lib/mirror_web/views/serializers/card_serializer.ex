defmodule MirrorWeb.CardSerializer do
  use JaSerializer

  def id(card, _conn), do: card.id
  def type, do: "card"
end