defmodule Mirror.Repo.Migrations.AddTypeToRetrospective do
  use Ecto.Migration

  def change do
    create table(:retrospective_types) do
      add :name, :string

      timestamps()
    end

    alter table(:retrospectives) do
      add :type_id, references(:retrospective_types, on_delete: :nothing)
    end

    create index(:retrospectives, [:type_id])
  end
end
