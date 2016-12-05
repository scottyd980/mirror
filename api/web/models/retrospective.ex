defmodule Mirror.Retrospective do
  use Mirror.Web, :model

  alias Mirror.Repo

  schema "retrospectives" do
    field :name, :string
    field :state, :integer, default: 0
    field :isAnonymous, :boolean, default: true
    belongs_to :team, Mirror.Team
    belongs_to :moderator, Mirror.User
    belongs_to :type, Mirror.RetrospectiveType
    # type
    many_to_many :participants, Mirror.User, join_through: Mirror.RetrospectiveUser

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :state, :isAnonymous, :team_id, :moderator_id])
    |> validate_required([:name, :state, :isAnonymous, :team_id, :moderator_id])
  end

  def check_retrospective_in_progress(team) do
    retro_count = Repo.all(from retro in Mirror.Retrospective, where: retro.team_id == ^team.id)
    |> Enum.count

    in_progress = retro_count > 0

    retro = Repo.all(from retro in Mirror.Retrospective, where: retro.team_id == ^team.id)

    {in_progress, retro}
  end
end
