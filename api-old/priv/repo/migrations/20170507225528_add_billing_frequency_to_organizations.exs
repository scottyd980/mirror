defmodule Mirror.Repo.Migrations.AddBillingFrequencyToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :billing_frequency, :string
    end
  end
end
