defmodule Mirror.Retrospectives.Score do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mirror.Repo

  alias Mirror.Accounts.User
  alias Mirror.Retrospectives.Retrospective

  schema "retrospective_scores" do
    field :score, :integer
    belongs_to :user, User
    belongs_to :retrospective, Retrospective

    timestamps()
  end

  @doc false
  def changeset(score, attrs) do
    score
    |> cast(attrs, [:score, :user_id, :retrospective_id])
    |> validate_required([:score, :user_id, :retrospective_id])
    |> validate_inclusion(:score, 1..10)
  end

  def preload_relationships(score) do
    score
    |> Repo.preload([:user, :retrospective], force: true)
  end
end
