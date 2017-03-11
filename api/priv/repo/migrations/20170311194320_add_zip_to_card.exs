defmodule Mirror.Repo.Migrations.AddZipToCard do
  use Ecto.Migration

  def change do
    alter table(:cards) do
      add :zip_code, :string
    end
  end
end
