defmodule Mirror.Retrospectives.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mirror.Accounts.User
  alias Mirror.Retrospectives.Retrospective

  @primary_key false
  schema "retrospective_participants" do
    belongs_to :user, User
    belongs_to :retrospective, Retrospective

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:user_id, :retrospective_id])
    |> validate_required([:user_id, :retrospective_id])
  end
end
