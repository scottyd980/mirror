defmodule Mirror.Repo.Migrations.CreateRetrospectives do
  use Ecto.Migration

  def change do
    create table(:retrospectives) do
      add :name, :string
      add :state, :integer
      add :is_anonymous, :boolean, default: false, null: false
      add :cancelled, :boolean, default: false, null: false
      add :moderator_id, references(:users, on_delete: :nilify_all)
      add :team_id, references(:teams, on_delete: :delete_all)

      timestamps()
    end
    create index(:retrospectives, [:moderator_id])
    create index(:retrospectives, [:team_id])
  end
end
