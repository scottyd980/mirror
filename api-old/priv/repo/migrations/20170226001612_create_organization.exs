defmodule Mirror.Repo.Migrations.CreateOrganization do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
      add :uuid, :string

      timestamps()
    end

    create table(:organization_admin) do
      add :user_id, references(:users)
      add :organization_id, references(:organizations)

      timestamps()
    end

    create table(:organization_user) do
      add :user_id, references(:users)
      add :organization_id, references(:organizations)

      timestamps()
    end
  end
end
