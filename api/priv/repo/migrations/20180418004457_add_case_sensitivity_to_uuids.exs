defmodule Mirror.Repo.Migrations.AddCaseSensitivityToUuids do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE organizations MODIFY uuid VARCHAR(255) COLLATE utf8_bin;"
    execute "ALTER TABLE teams MODIFY uuid VARCHAR(255) COLLATE utf8_bin;"
    execute "ALTER TABLE users MODIFY password_hash VARCHAR(255) COLLATE utf8_bin;"
  end
end
