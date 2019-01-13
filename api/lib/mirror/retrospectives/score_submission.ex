defmodule Mirror.Retrospectives.ScoreSubmission do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mirror.Repo

  alias Mirror.Accounts.User
  alias Mirror.Retrospectives.Retrospective

  schema "retrospective_score_submissions" do
    field :submitted, :boolean, default: false
    belongs_to :user, User
    belongs_to :retrospective, Retrospective

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:submitted, :user_id, :retrospective_id])
    |> validate_required([:submitted, :user_id, :retrospective_id])
    |> unique_constraint(:user_id, name: :retrospective_score_submissions_unique_score)
  end

  def preload_relationships(submission) do
    submission
    |> Repo.preload([:user, :retrospective], force: true)
  end
end
