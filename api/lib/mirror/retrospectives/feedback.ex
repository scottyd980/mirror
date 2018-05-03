defmodule Mirror.Retrospectives.Feedback do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mirror.Repo

  alias Mirror.Accounts.User
  alias Mirror.Retrospectives.Retrospective

  schema "retrospective_feedbacks" do
    field :category, :string
    field :message, :string
    field :state, :integer, default: 0
    belongs_to :user, User
    belongs_to :retrospective, Retrospective

    timestamps()
  end

  @doc false
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [:category, :message, :state, :user_id, :retrospective_id])
    |> validate_required([:category, :message, :user_id, :retrospective_id])
  end

  def preload_relationships(feedback) do
    feedback
    |> Repo.preload([:user, :retrospective], force: true)
  end
end
