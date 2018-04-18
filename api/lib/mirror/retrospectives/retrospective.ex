defmodule Mirror.Retrospectives.Retrospective do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mirror.Repo

  alias Mirror.Accounts.User
  alias Mirror.Teams.Team

  schema "retrospectives" do
    field :cancelled, :boolean, default: false
    field :is_anonymous, :boolean, default: false
    field :name, :string
    field :state, :integer
    belongs_to :team, Team
    belongs_to :moderator, User

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
    |> Repo.preload([:team, :moderator], force: true)
    # |> Repo.preload([:team, :moderator, :participants, :scores, :feedbacks, :type], force: true)
  end
end
