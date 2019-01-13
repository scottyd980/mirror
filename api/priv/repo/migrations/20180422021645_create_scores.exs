defmodule Mirror.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:retrospective_scores) do
      add :score, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :retrospective_id, references(:retrospectives, on_delete: :nothing)

      timestamps()
    end

  end
end
