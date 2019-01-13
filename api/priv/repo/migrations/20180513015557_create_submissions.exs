defmodule Mirror.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    # Score submissions
    create table(:retrospective_score_submissions) do
      add :submitted, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :retrospective_id, references(:retrospectives, on_delete: :delete_all)

      timestamps()
    end

    create index(:retrospective_score_submissions, [:user_id])
    create index(:retrospective_score_submissions, [:retrospective_id])
    create unique_index(:retrospective_score_submissions, [:user_id, :retrospective_id], name: :retrospective_score_submissions_unique_score)

    # Feedback submissions
    create table(:retrospective_feedback_submissions) do
      add :submitted, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :retrospective_id, references(:retrospectives, on_delete: :delete_all)

      timestamps()
    end

    create index(:retrospective_feedback_submissions, [:user_id])
    create index(:retrospective_feedback_submissions, [:retrospective_id])
    create unique_index(:retrospective_feedback_submissions, [:user_id, :retrospective_id], name: :retrospective_feedback_submissions_unique_feedback)
  end
end
