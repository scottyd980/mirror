defmodule Mirror.CardView do
  use Mirror.Web, :view

  def render("index.json", %{cards: cards}) do
    %{data: render_many(cards, Mirror.CardView, "card.json")}
  end

  def render("show.json", %{card: card}) do
    %{data: render_one(card, Mirror.CardView, "card.json")}
  end

  def render("card.json", %{card: card}) do
    %{id: card.id,
      brand: card.brand,
      last4: card.last4,
      exp_month: card.exp_month,
      exp_year: card.exp_year,
      token_id: card.token_id,
      card_id: card.card_id}
  end
end
