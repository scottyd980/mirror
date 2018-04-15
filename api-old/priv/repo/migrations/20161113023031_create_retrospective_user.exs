defmodule Mirror.Repo.Migrations.CreateRetrospectiveUser do
  use Ecto.Migration

  def change do
    create table(:retrospective_participants) do
      add :user_id, references(:users)
      add :retrospective_id, references(:retrospectives)

      timestamps()
    end
  end
end
