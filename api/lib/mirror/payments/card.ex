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
    |> validate_required([:brand, :last4, :exp_month, :exp_year, :card_id, :organization_id])
  end

  def webhook_changeset(card, attrs) do
    card
    |> cast(attrs, [:exp_month, :exp_year])
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

  def delete(card) do
    Repo.transaction fn ->
      if Card.is_default_payment?(card) do
        Organization.set_alternate_default_payment(card)
      end

      with removed_card           <- Repo.delete!(card),
           {:ok, removed_billing} <- Stripe.Card.delete(card.card_id, %{customer: card.organization.billing_customer})
      do
        {:ok, removed_card}
      else
        {:error, changeset} ->
          Repo.rollback changeset
          {:error, changeset}
      end
    end
  end

  def update_expiration_date(card, attrs) do
    card
    |> Card.webhook_changeset(attrs)
    |> Repo.update()
  end

  def is_default_payment?(card) do
    card = card
    |> Card.preload_relationships

    card.organization.default_payment_id == card.id
  end

  # TODO: Implement get_status
  def get_status(card) do
    case card do
      nil -> :invalid
      _ -> :valid
    end
  end
end
