defmodule Mirror.Repo.Migrations.CreateActions do
  use Ecto.Migration

  def change do
    create table(:retrospective_actions) do
      add :message, :text
      add :feedback_id, references(:retrospective_feedbacks, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
