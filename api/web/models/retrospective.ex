defmodule Mirror.Retrospective do
  use Mirror.Web, :model

  alias Mirror.{Repo, Retrospective, RetrospectiveType, RetrospectiveUser, User, Feedback, SprintScore, Team}

  import Logger

  schema "retrospectives" do
    field :name, :string
    field :state, :integer, default: 0
    field :isAnonymous, :boolean, default: true
    has_many :scores, SprintScore
    has_many :feedbacks, Feedback
    belongs_to :team, Team
    belongs_to :moderator, User
    belongs_to :type, RetrospectiveType
    many_to_many :participants, User, join_through: RetrospectiveUser

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :state, :isAnonymous, :team_id, :moderator_id, :type_id])
    |> validate_required([:name, :state, :isAnonymous, :team_id, :moderator_id, :type_id])
  end

  def check_retrospective_in_progress(team) do
    retro = get_retro_in_progress(team)

    retro_count = retro
    |> Enum.count

    in_progress = retro_count > 0

    {in_progress, retro}
  end

  def preload_relationships(retrospective) do
    retrospective
    |> Repo.preload([:team, :moderator, :participants, :scores, :feedbacks, :type])
  end

  def get_retro_in_progress(team) do
    retro = Repo.all(from retro in Retrospective, where: retro.team_id == ^team.id)

    retro_in_progress = retro
    |> Enum.filter(fn(r) ->
      retro_type = Repo.get!(RetrospectiveType, r.type_id)
      r.state < retro_type.finished_state
    end)
    
    retro_in_progress
  end
end
