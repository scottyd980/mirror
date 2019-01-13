defmodule Mirror.Repo.Migrations.AddBillingToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :billing_customer, :string
      add :billing_status, :string
      add :billing_frequency, :string
      add :default_payment_id, references(:payment_cards)
    end
  end
end
