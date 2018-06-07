defmodule Mirror.Payments.Card do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mirror.Repo

  alias Mirror.Organizations.Organization
  alias Mirror.Payments.Card

  schema "payment_cards" do
    field :brand, :string
    field :card_id, :string
    field :exp_month, :integer
    field :exp_year, :integer
    field :last4, :string
    field :token_id, :string
    field :zip_code, :string
    belongs_to :organization, Organization

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:brand, :last4, :exp_month, :exp_year, :token_id, :card_id, :organization_id, :zip_code])
    |> validate_required([:brand, :last4, :exp_month, :exp_year, :token_id, :card_id, :organization_id, :zip_code])
  end

  def preload_relationships(card) do
    card
    |> Repo.preload([:organization], force: true)
  end

  def create(attrs) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert
  end
end
