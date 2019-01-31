defmodule Mirror.Repo.Migrations.UpdateUserFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :display_name, :string
      add :reset_password_token, :string
      add :reset_token_sent_at, :bigint
    end
  end
end
