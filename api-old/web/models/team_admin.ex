defmodule Mirror.TeamAdmin do
  use Mirror.Web, :model

  @primary_key false
  schema "team_admin" do
    belongs_to :user, Mirror.User
    belongs_to :team, Mirror.Team

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :team_id])
    |> validate_required([:user_id, :team_id])
  end
end
