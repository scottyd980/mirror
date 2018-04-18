defmodule Mirror.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:organization_members) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end
  end
end
