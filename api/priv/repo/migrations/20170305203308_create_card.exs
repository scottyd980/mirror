defmodule Mirror.Repo.Migrations.CreateCard do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :brand, :string
      add :last4, :string
      add :exp_month, :integer
      add :exp_year, :integer
      add :token_id, :string
      add :card_id, :string
      add :organization_id, references(:organizations)

      timestamps()
    end

    alter table(:organizations) do
      add :default_payment_id, references(:cards)
    end
  end
end