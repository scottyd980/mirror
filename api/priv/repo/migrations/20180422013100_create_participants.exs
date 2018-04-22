defmodule Mirror.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:retrospective_participants) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :retrospective_id, references(:retrospectives, on_delete: :delete_all)

      timestamps()
    end
  end
end
