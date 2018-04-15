defmodule Mirror.Repo.Migrations.CreateAction do
  use Ecto.Migration

  def change do
    create table(:actions) do
      add :message, :text
      add :feedback_id, references(:feedbacks)

      timestamps()
    end
  end
end
