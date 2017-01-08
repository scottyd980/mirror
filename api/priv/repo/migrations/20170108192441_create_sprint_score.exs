defmodule Mirror.Repo.Migrations.CreateSprintScore do
  use Ecto.Migration

  def change do
    create table(:sprint_scores) do
      add :score, :integer
      add :user_id, references(:users)
      add :retrospective_id, references(:retrospectives)

      timestamps()
    end

  end
end
