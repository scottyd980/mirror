defmodule Mirror.Repo.Migrations.AddOrganizationToTeam do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :organization_id, references(:organizations, on_delete: :nilify_all)
    end
  end
end
