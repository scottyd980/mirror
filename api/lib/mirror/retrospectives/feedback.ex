defmodule Mirror.Retrospectives.Feedback do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mirror.Repo

  alias Mirror.Accounts.User
  alias Mirror.Retrospectives.Retrospective
  alias Mirror.Retrospectives.Action

  schema "retrospective_feedbacks" do
    field :category, :string
    field :message, :string
    field :state, :integer, default: 0
    belongs_to :user, User
    belongs_to :retrospective, Retrospective
    has_many :actions, Action, on_delete: :delete_all

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
    |> Repo.preload([:user, :retrospective, :actions], force: true)
  end
end
