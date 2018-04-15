defmodule Mirror.Repo.Migrations.CreateFeedback do
  use Ecto.Migration

  def change do
    create table(:feedbacks) do
      add :type, :string
      add :message, :text
      add :state, :integer
      add :user_id, references(:users)
      add :retrospective_id, references(:retrospectives)

      timestamps()
    end
  end
end
