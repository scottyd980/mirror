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

  def preload_relationships(retrospective) do
    retrospective
    |> Repo.preload([:team, :moderator, :participants, :scores, :feedbacks, :type])
  end
end
