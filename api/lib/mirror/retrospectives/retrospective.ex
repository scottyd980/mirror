defmodule Mirror.Retrospectives.Retrospective do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mirror.Repo

  alias Mirror.Accounts.User
  alias Mirror.Teams.Team
  alias Mirror.Retrospectives.{Participant, Score, Feedback}

  schema "retrospectives" do
    field :cancelled, :boolean, default: false
    field :is_anonymous, :boolean, default: false
    field :name, :string
    field :state, :integer
    belongs_to :team, Team
    belongs_to :moderator, User
    has_many :scores, Score, on_delete: :delete_all
    has_many :feedbacks, Feedback, on_delete: :delete_all
    many_to_many :participants, User, join_through: Participant

    timestamps()
  end

  @doc false
  def changeset(retrospective, attrs) do
    retrospective
    |> cast(attrs, [:name, :state, :is_anonymous, :cancelled, :team_id, :moderator_id])
    |> validate_required([:name, :state, :is_anonymous, :cancelled, :team_id, :moderator_id])
  end

  def preload_relationships(retrospective) do
    retrospective
    |> Repo.preload([:team, :moderator, :participants, :scores], force: true)
    # |> Repo.preload([:team, :moderator, :participants, :scores, :feedbacks, :type], force: true)
  end
end
