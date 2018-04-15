defmodule Mirror.Repo.Migrations.AddMultipleAdmins do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE teams DROP FOREIGN KEY teams_admin_id_fkey"

    alter table(:teams) do
      remove :admin_id
    end

    create table(:team_admin) do
      add :user_id, references(:users)
      add :team_id, references(:teams)

      timestamps()
    end
  end
end
