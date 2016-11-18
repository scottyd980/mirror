defmodule Mirror.Repo.Migrations.CreateRetrospectiveTable do
  use Ecto.Migration

  def change do
    create table(:retrospectives) do
      add :name, :string
      add :state, :integer, default: 0, null: false
      add :isAnonymous, :boolean, default: true, null: false
      add :moderator_id, references(:users, on_delete: :nothing)
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps()
    end
    create index(:retrospectives, [:moderator_id])
    create index(:retrospectives, [:team_id])
  end
end
