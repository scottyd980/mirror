defmodule MirrorWeb.PaymentCardView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView
  require Calendar

  alias MirrorWeb.{OrganizationSerializer}
  alias Mirror.Helpers

  attributes [:brand, :last4, :exp_month, :exp_year, :token_id, :card_id, :zip_code, :added_date, :is_expired]

  has_one :organization,
    links: [
      self: "/api/organizations/"
    ],
    serializer: OrganizationSerializer,
    include: false,
    identifiers: :always

  def render("delete.json-api", _) do
    %{meta: %{}}
  end

  def type, do: "card"

  def added_date(struct, _conn) do
    struct.inserted_at
  end

  def is_expired(struct, _conn) do
    Helpers.Card.is_expired?(struct)
  end
end
