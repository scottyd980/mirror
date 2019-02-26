defmodule Mirror.Repo.Migrations.UpdateDeleteConstraints do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE retrospective_scores drop foreign key retrospective_scores_user_id_fkey"
    execute "ALTER TABLE retrospective_scores drop foreign key retrospective_scores_retrospective_id_fkey"
    execute "ALTER TABLE retrospective_feedbacks drop foreign key retrospective_feedbacks_user_id_fkey"
    execute "ALTER TABLE retrospective_actions drop foreign key retrospective_actions_user_id_fkey"

    alter table(:retrospective_scores) do
      modify :user_id, references(:users, on_delete: :delete_all)
      modify :retrospective_id, references(:retrospectives, on_delete: :delete_all)
    end

    alter table(:retrospective_feedbacks) do
      modify :user_id, references(:users, on_delete: :delete_all)
    end

    alter table(:retrospective_actions) do
      modify :user_id, references(:users, on_delete: :delete_all)
    end
  end

  def down do
    execute "ALTER TABLE retrospective_scores drop foreign key retrospective_scores_user_id_fkey"
    execute "ALTER TABLE retrospective_scores drop foreign key retrospective_scores_retrospective_id_fkey"
    execute "ALTER TABLE retrospective_feedbacks drop foreign key retrospective_feedbacks_user_id_fkey"
    execute "ALTER TABLE retrospective_actions drop foreign key retrospective_actions_user_id_fkey"

    alter table(:address) do
      modify :user_id, references(:users, on_delete: :nothing)
      modify :retrospective_id, references(:retrospectives, on_delete: :nothing)
    end

    alter table(:retrospective_feedbacks) do
      modify :user_id, references(:users, on_delete: :nothing)
    end

    alter table(:retrospective_actions) do
      modify :user_id, references(:users, on_delete: :nothing)
    end
  end
end
