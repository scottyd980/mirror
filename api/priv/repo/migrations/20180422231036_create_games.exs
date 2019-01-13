defmodule Mirror.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:retrospective_games) do
      add :name, :string
      add :finished_state, :integer

      timestamps()
    end

    alter table(:retrospectives) do
      add :game_id, references(:retrospective_games, on_delete: :nothing)
    end

    create index(:retrospectives, [:game_id])
  end
end
