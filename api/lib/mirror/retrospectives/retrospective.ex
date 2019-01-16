defmodule Mirror.Retrospectives.Retrospective do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mirror.Repo

  alias Mirror.Accounts.User
  alias Mirror.Teams
  alias Mirror.Teams.Team
  alias Mirror.Retrospectives.{Retrospective, Participant, Score, Feedback, Game, FeedbackSubmission, ScoreSubmission}

  schema "retrospectives" do
    field :cancelled, :boolean, default: false
    field :is_anonymous, :boolean, default: false
    field :name, :string
    field :state, :integer
    belongs_to :team, Team
    belongs_to :moderator, User
    belongs_to :game, Game
    has_many :scores, Score, on_delete: :delete_all
    has_many :feedbacks, Feedback, on_delete: :delete_all
    has_many :feedback_submissions, FeedbackSubmission, on_delete: :delete_all
    has_many :score_submissions, ScoreSubmission, on_delete: :delete_all
    many_to_many :participants, User, join_through: Participant

    timestamps()
  end

  @doc false
  def changeset(retrospective, attrs) do
    retrospective
    |> cast(attrs, [:name, :state, :is_anonymous, :cancelled, :team_id, :moderator_id, :game_id])
    |> validate_required([:name, :state, :is_anonymous, :cancelled, :team_id, :moderator_id, :game_id])
  end

  def preload_relationships(retrospective) do
    retrospective
    |> Repo.preload([:team, :moderator, :participants, :scores, :feedbacks, :game, :feedback_submissions, :score_submissions], force: true)
  end

  # TODO: Should probably make sure that a retrospective is not in progress for this team
  def create(params) do
    team = Teams.get_team!(params["team_uuid"])
    case Team.check_retrospective_in_progress(team) do
      {true, _}->
        {:error, :retrospective_in_progress}
      {false, _} ->
        %Retrospective{}
          |> Retrospective.changeset(%{
          name: params["name"],
          state: params["state"],
          is_anonymous: params["is_anonymous"],
          cancelled: false,
          team_id: params["team_id"],
          moderator_id: params["moderator_id"],
          game_id: params["game"]
        })
        |> Repo.insert
    end
  end

  def add_participants(retrospective, participants) do
    cond do
      length(participants) > 0 ->
        Enum.map participants, fn participant ->
          %Participant{}
          |> Participant.changeset(%{user_id: participant, retrospective_id: retrospective.id})
          |> Repo.insert
        end
      true ->
        [{:ok, nil}]
    end
  end
end
