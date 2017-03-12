defmodule Mirror.Card do
  use Mirror.Web, :model

  alias Mirror.{Repo, Card, Organization, Billing}

  schema "cards" do
    field :brand, :string
    field :last4, :string
    field :exp_month, :integer
    field :exp_year, :integer
    field :token_id, :string
    field :card_id, :string
    field :zip_code, :string
    belongs_to :organization, Organization

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:brand, :last4, :exp_month, :exp_year, :token_id, :card_id, :organization_id, :zip_code])
    |> validate_required([:brand, :last4, :exp_month, :exp_year, :token_id, :card_id, :organization_id, :zip_code])
  end

  def preload_relationships(card) do
    card
    |> Repo.preload([:organization], force: true)
  end

  # Read
  def get(card_id) do
    Repo.get_by!(Card, card_id: card_id)
    |> Card.preload_relationships()
  end

  # Create
  def create(card_params) do
    Repo.transaction fn ->
      with {:ok, card} <- insert_card(card_params),
           {:ok, cust_card} <- insert_customer_card(card_params) do
             card
             |> Card.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
          {:error, changeset}
      end
    end
  end

  defp insert_card(card_params) do
    %Card{}
    |> Card.changeset(card_params)
    |> Repo.insert
  end

  defp insert_customer_card(card_params) do
    Billing.add_payment(card_params.customer, card_params.token_id)
  end

  # TODO - Re-evaluate, do these belong here?
  def make_default(card, organization) do
    Repo.transaction fn ->
      with {:ok, updated_org} <- insert_default_card(card, organization),
           {:ok, updated_cust} <- Billing.update_default_payment(organization.billing_customer, card.card_id)do
             updated_org
             |> Organization.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
          {:error, changeset}
      end
    end
  end

  defp insert_default_card(card, organization) do
    Organization.changeset(organization, %{default_payment_id: card.id})
    |> Repo.update
  end

  # Update
  def update(card) do
    
  end

  # Delete
  def delete(card) do
    Repo.transaction fn ->
      with removed_card <- delete_card(card),
            {:ok, removed_customer_card} <- delete_customer_card(card)
      do
        {:ok, removed_card}
      else
        {:error, changeset} ->
          Repo.rollback changeset
          {:error, changeset}
      end
    end
  end

  defp delete_card(card) do
    Repo.delete!(card)
  end

  defp delete_customer_card(card) do
    Billing.delete_payment(card.organization.billing_customer, card.card_id)
  end
end
