defmodule Mirror.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :avatar, :string
      add :uuid, :string
      add :is_anonymous, :boolean, default: false, null: false

      timestamps()
    end

  end
end
