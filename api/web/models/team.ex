defmodule Mirror.Team do
  use Mirror.Web, :model

  schema "teams" do
    field :name, :string
    field :isAnonymous, :boolean, default: false
    field :avatar, :string
    field :uuid, :string
    many_to_many :admins, Mirror.User, join_through: Mirror.TeamAdmin
    many_to_many :members, Mirror.User, join_through: Mirror.UserTeam

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :isAnonymous, :avatar, :uuid])
    # |> cast_assoc(:admin)
    |> validate_required([:name, :isAnonymous, :avatar])
    # |> assoc_constraint(:admin)
  end
end
