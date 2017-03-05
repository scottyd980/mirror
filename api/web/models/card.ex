defmodule Mirror.Card do
  use Mirror.Web, :model

  alias Mirror.{Repo, Organization}

  schema "cards" do
    field :brand, :string
    field :last4, :string
    field :exp_month, :integer
    field :exp_year, :integer
    field :token_id, :string
    field :card_id, :string
    belongs_to :organization, Organization

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:brand, :last4, :exp_month, :exp_year, :token_id, :card_id, :organization_id])
    |> validate_required([:brand, :last4, :exp_month, :exp_year, :token_id, :card_id, :organization_id])
  end

  def preload_relationships(card) do
    card
    |> Repo.preload([:organization])
  end
end
