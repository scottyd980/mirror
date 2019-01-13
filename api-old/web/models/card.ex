defmodule Mirror.Card do
  use Mirror.Web, :model

  alias Mirror.{Repo, Card, Organization, Billing}

  require Logger

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
      with {:ok, card}      <- insert_card(card_params),
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
    Logger.warn "#{inspect card_params}"
    Billing.add_payment(card_params.customer, card_params.token_id)
  end

  # Update
  def update(card) do
    
  end

  # Delete
  def delete(card) do
      case Organization.is_default_payment?(card.organization, card) do
          true ->
            case Organization.set_default_payment(card.organization) do
                {:ok, nil} ->           remove_card(card, :default)
                {:ok, new_default} ->   remove_card(card)
                {:error, changeset} ->  {:error, changeset}
            end
          _ ->
            remove_card(card)
      end
  end

  defp remove_card(card) do
    Repo.transaction fn ->
      with removed_card                 <- delete_card(card),
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

  defp remove_card(card, :default) do
    Repo.transaction fn ->
        with {:ok, updated_org}             <- Organization.remove_default_payment(card.organization),
             removed_card                   <- delete_card(card),
             {:ok, removed_customer_card}   <- delete_customer_card(card)
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
