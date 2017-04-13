defmodule Mirror.Repo.Migrations.AddBillingStatusToOrganization do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :billing_status, :string
    end
  end
end
