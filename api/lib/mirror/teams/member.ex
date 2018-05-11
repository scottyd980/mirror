defmodule Mirror.Teams.Member do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mirror.Repo

  alias Mirror.Teams.Team
  alias Mirror.Accounts.User

  @primary_key false
  schema "team_members" do
    belongs_to :user, User
    belongs_to :team, Team

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :team_id])
    |> validate_required([:user_id, :team_id])
  end

  def preload_relationships(member) do
    member
    |> Repo.preload([:user, :team], force: true)
  end
end
  