defmodule Mirror.Retrospective do
  use Mirror.Web, :model

  schema "retrospectives" do
    field :name, :string
    field :state, :integer, default: 0
    field :isAnonymous, :boolean, default: true
    belongs_to :team, Mirror.Team
    belongs_to :moderator, Mirror.User
    # type
    many_to_many :participants, Mirror.User, join_through: Mirror.RetrospectiveUser

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :state, :isAnonymous])
    |> validate_required([:name, :state, :isAnonymous])
  end
end
