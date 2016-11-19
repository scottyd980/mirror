defmodule Mirror.Repo.Migrations.AddManyUsersToManyTeams do
  use Ecto.Migration

  def change do
    create table(:user_team) do
      add :user_id, references(:users)
      add :team_id, references(:teams)

      timestamps()
    end
  end
end
