defmodule Mirror.Teams.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mirror.Teams.Team
  alias Mirror.Accounts.User

  @primary_key false
  schema "team_admins" do
    belongs_to :user, User
    belongs_to :team, Team

    timestamps()
    end

    def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :team_id])
    |> validate_required([:user_id, :team_id])
  end
end
