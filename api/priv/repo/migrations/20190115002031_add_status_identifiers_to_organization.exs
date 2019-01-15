defmodule Mirror.Repo.Migrations.AddStatusIdentifiersToOrganization do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :is_delinquent, :boolean, default: false
      add :is_deleted, :boolean, default: false
    end
  end
end
