defmodule Mirror.Repo.Migrations.CreateWebhooksTable do
  use Ecto.Migration

  def change do
    create table(:stripe_events) do
      add :event_id, :string

      timestamps()
    end

    create index(:stripe_events, [:event_id])
  end
end
