defmodule Mirror.Team do
  use Mirror.Web, :model

  schema "teams" do
    field :name, :string
    field :isAnonymous, :boolean, default: false
    field :avatar, :string
    belongs_to :admin, Mirror.User
    many_to_many :members, Mirror.User, join_through: "users_teams"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :isAnonymous, :avatar])
    |> validate_required([:name, :isAnonymous, :avatar])
  end
end
