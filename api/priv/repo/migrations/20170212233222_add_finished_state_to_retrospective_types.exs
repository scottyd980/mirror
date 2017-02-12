defmodule Mirror.Repo.Migrations.AddFinishedStateToRetrospectiveTypes do
  use Ecto.Migration

  def change do
    alter table(:retrospective_types) do
      add :finished_state, :integer
    end
  end
end
