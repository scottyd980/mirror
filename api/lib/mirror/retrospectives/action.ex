defmodule Mirror.Retrospectives.Action do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mirror.Repo

  alias Mirror.Retrospectives.Feedback
  alias Mirror.Accounts.User

  schema "retrospective_actions" do
    field :message, :string
    belongs_to :feedback, Feedback
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(action, attrs) do
    action
    |> cast(attrs, [:message, :user_id, :feedback_id])
    |> validate_required([:message, :user_id, :feedback_id])
  end

  def preload_relationships(action) do
    action
    |> Repo.preload([:feedback, :user], force: true)
  end
end
