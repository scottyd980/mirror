defmodule Mirror.Repo.Migrations.CreateFeedbacks do
  use Ecto.Migration

  def change do
    create table(:retrospective_feedbacks) do
      add :category, :string
      add :message, :text
      add :state, :integer
      add :user_id, references(:users, on_delete: :delete_all)
      add :retrospective_id, references(:retrospectives, on_delete: :delete_all)

      timestamps()
    end

  end
end
