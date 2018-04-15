defmodule Mirror.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :isAnonymous, :boolean, default: true, null: true
      add :avatar, :string
      add :admin_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:teams, [:admin_id])

  end
end
