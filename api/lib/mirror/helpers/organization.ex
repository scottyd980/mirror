defmodule Mirror.Helpers.Organization do
  alias Mirror.Payments
  alias Mirror.Payments.Card

  require Logger

  def card_on_file?(organization, card_id) do
    case card_id do
      nil -> true
      _ -> 
        card = Payments.get_card!(card_id)
        |> Card.preload_relationships()

        card.organization.id == organization.id
    end
  end
end
