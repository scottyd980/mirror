defmodule Mirror.Helpers.Organization do
  alias Mirror.Payments
  alias Mirror.Payments.Card
  alias Mirror.Helpers

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

  def valid_card_update?(organization, card_id) do
    case card_id do
      nil -> {:ok, :none}
      _ ->
        case card_modified?(organization, card_id) do
          true ->
            card = Payments.get_card!(card_id)
            case Helpers.Card.is_expired?(card) do
              false -> {:ok, :modified}
              true -> {:error, :expired}
            end
          _ -> {:ok, :unmodified}
        end
    end
  end

  def card_modified?(organization, card_id) do
    organization.default_payment_id != card_id
  end

  def frequency_modified?(organization, updated_organization) do
    organization.billing_frequency != updated_organization.billing_frequency
  end
end
