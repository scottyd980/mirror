defmodule Mirror.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:payment_cards) do
      add :brand, :string
      add :last4, :string
      add :exp_month, :integer
      add :exp_year, :integer
      add :token_id, :string
      add :card_id, :string
      add :zip_code, :string
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

  end
end
