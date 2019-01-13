defmodule Mirror.Repo.Migrations.CreateMemberDelegate do
  use Ecto.Migration

  def change do
    create table(:member_delegate) do
      add :email, :string
      add :access_code, :string
      add :is_accessed, :boolean, default: false, null: false
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps()
    end
    create index(:member_delegate, [:team_id])
  end
end
