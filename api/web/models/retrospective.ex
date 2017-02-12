defmodule Mirror.Retrospective do
  use Mirror.Web, :model

  alias Mirror.{Repo}

  schema "retrospectives" do
    field :name, :string
    field :state, :integer, default: 0
    field :isAnonymous, :boolean, default: true
    has_many :scores, Mirror.SprintScore
    has_many :feedbacks, Mirror.Feedback
    belongs_to :team, Mirror.Team
    belongs_to :moderator, Mirror.User
    belongs_to :type, Mirror.RetrospectiveType
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
    retro = Repo.all(from retro in Mirror.Retrospective, where: retro.team_id == ^team.id)

    # TODO - change 6 to be dynamic based on game

    retro_count = retro
    |> Enum.filter(fn(r) -> r.state < 6 end)
    |> Enum.count

    in_progress = retro_count > 0

    {in_progress, retro}
  end

  def preload_relationships(retrospective) do
    retrospective
    |> Repo.preload([:team, :moderator, :participants, :scores, :feedbacks])
  end
end
