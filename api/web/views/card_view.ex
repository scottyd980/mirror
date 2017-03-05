defmodule Mirror.CardView do
  use Mirror.Web, :view

  def render("index.json", %{cards: cards}) do
    %{data: render_many(cards, Mirror.CardView, "card.json")}
  end

  def render("show.json", %{card: card}) do
    %{data: render_one(card, Mirror.CardView, "card.json")}
  end

  def render("card.json", %{card: card}) do
    %{
    	"type": "card",
    	"id": card.card_id,
    	"attributes": %{
        "brand": card.brand,
        "last4": card.last4,
        "exp-month": card.exp_month,
        "exp-year": card.exp_year,
        "added-date": card.inserted_at
    	},
      "relationships": %{
        "organization": %{
          "links": %{
            "self": "/api/organizations/"
          },
          "data": render_one(card.organization, Mirror.OrganizationView, "relationship.json", as: :organization)
      	}
      }
    }
  end

  def render("relationship.json", %{card: card}) do
    %{
      "type": "card",
      "id": card.card_id
    }
  end
end
