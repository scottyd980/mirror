defmodule Mirror.Repo.Migrations.CreateMemberDelegates do
  use Ecto.Migration

  def change do
    create table(:team_member_delegates) do
      add :email, :string
      add :access_code, :string
      add :is_accessed, :boolean, default: false, null: false
      add :team_id, references(:teams, on_delete: :delete_all)

      timestamps()
    end
    create index(:team_member_delegates, [:team_id])
  end
end
