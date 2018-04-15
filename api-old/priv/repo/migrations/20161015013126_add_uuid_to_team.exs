defmodule Mirror.Repo.Migrations.AddUuidToTeam do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :uuid, :string
    end
  end
end
