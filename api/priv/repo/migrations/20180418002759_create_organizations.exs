defmodule Mirror.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
      add :uuid, :string
      add :avatar, :string

      timestamps()
    end

    execute "ALTER TABLE organizations MODIFY uuid VARCHAR(255) COLLATE utf8_bin;"
  end
end
