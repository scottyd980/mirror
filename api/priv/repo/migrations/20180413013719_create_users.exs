defmodule Mirror.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password_hash, :string

      timestamps()
    end

    create index(:users, [:email], unique: true)
    create index(:users, [:username], unique: true)
    execute "ALTER TABLE users MODIFY password_hash VARCHAR(255) COLLATE utf8_bin;"
  end
end