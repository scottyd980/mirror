defmodule Mirror.Repo.Migrations.AddAvatarToOrganization do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :avatar, :string
    end
  end
end
