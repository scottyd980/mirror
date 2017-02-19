defmodule Mirror.Repo.Migrations.AddCancelToRetrospective do
  use Ecto.Migration

  def change do
    alter table(:retrospectives) do
      add :cancelled, :boolean
    end
  end
end
