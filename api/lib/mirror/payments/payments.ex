defmodule Mirror.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias Mirror.Repo

  alias Mirror.Payments.Card
  alias Mirror.Organizations.Organization

  @doc """
  Returns the list of cards.

  ## Examples

      iex> list_cards()
      [%Card{}, ...]

  """
  def list_cards(organization) do
    query = from r in Card,
            where: r.organization_id == ^organization.id
    Repo.all(query)
  end

  @doc """
  Gets a single card.

  Raises `Ecto.NoResultsError` if the Card does not exist.

  ## Examples

      iex> get_card!(123)
      %Card{}

      iex> get_card!(456)
      ** (Ecto.NoResultsError)

  """
  def get_card!(id), do: Repo.get!(Card, id)

  @doc """
  Creates a card.

  ## Examples

      iex> create_card(%{field: value})
      {:ok, %Card{}}

      iex> create_card(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_card(attrs \\ %{}, default \\ true) do
    Repo.transaction fn ->
      with  {:ok, %Card{} = card}   <- Card.create(attrs),
            {:ok, stripe_card}      <- Stripe.Card.create(%{customer: attrs["customer"], source: attrs["token_id"]}),
            {:ok, %Organization{}}  <- Organization.set_default_payment(card, default),
            preload_card            <- Card.preload_relationships(card),
            {:ok, %Organization{}}  <- Organization.set_billing_status(preload_card.organization)
      do
        card
      else
        {:error, changeset} ->
          Repo.rollback changeset
          {:error, changeset}
        _ ->
          {:error, :unknown}
      end
    end
  end

  @doc """
  Updates a card.

  ## Examples

      iex> update_card(card, %{field: new_value})
      {:ok, %Card{}}

      iex> update_card(card, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_card(%Card{} = card, attrs) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Card.

  ## Examples

      iex> delete_card(card)
      {:ok, %Card{}}

      iex> delete_card(card)
      {:error, %Ecto.Changeset{}}

  """
  def delete_card(%Card{} = card) do
    {:ok, resp} = Card.delete(card)

    resp
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking card changes.

  ## Examples

      iex> change_card(card)
      %Ecto.Changeset{source: %Card{}}

  """
  def change_card(%Card{} = card) do
    Card.changeset(card, %{})
  end
end
