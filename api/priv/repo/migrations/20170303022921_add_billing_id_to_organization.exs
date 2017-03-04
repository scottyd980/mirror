defmodule Mirror.Repo.Migrations.AddBillingIdToOrganization do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :billing_customer, :string
    end
  end
end
