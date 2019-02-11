defmodule Mirror.Repo.Migrations.AddActiveFeedbackIdToRetrsopective do
  use Ecto.Migration

  def change do
    alter table(:retrospectives) do
      add :active_feedback_id, references(:retrospective_feedbacks)
    end
  end
end
