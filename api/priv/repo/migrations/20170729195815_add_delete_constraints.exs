defmodule Mirror.Repo.Migrations.AddDeleteConstraints do
  use Ecto.Migration

  def change do
    # Cards Table
    execute "ALTER TABLE cards DROP FOREIGN KEY cards_organization_id_fkey"
    alter table(:cards) do
      modify :organization_id, references(:organizations, on_delete: :delete_all)
    end

    # Feedbacks Table
    execute "ALTER TABLE feedbacks DROP FOREIGN KEY feedbacks_retrospective_id_fkey"
    alter table(:feedbacks) do
      modify :retrospective_id, references(:retrospectives, on_delete: :delete_all)
    end
    
    execute "ALTER TABLE feedbacks DROP FOREIGN KEY feedbacks_user_id_fkey"
    alter table(:feedbacks) do
      modify :user_id, references(:users, on_delete: :nilify_all)
    end

    # Member Delegates Table
    execute "ALTER TABLE member_delegate DROP FOREIGN KEY member_delegate_team_id_fkey"
    alter table(:member_delegate) do
      modify :team_id, references(:teams, on_delete: :delete_all)
    end

    # Organization/Admin Join Table
    execute "ALTER TABLE organization_admin DROP FOREIGN KEY organization_admin_organization_id_fkey"
    alter table(:organization_admin) do
      modify :organization_id, references(:organizations, on_delete: :delete_all)
    end

    execute "ALTER TABLE organization_admin DROP FOREIGN KEY organization_admin_user_id_fkey"
    alter table(:organization_admin) do
      modify :user_id, references(:users, on_delete: :delete_all)
    end

    # Organization/User Join Table
    execute "ALTER TABLE organization_user DROP FOREIGN KEY organization_user_organization_id_fkey"
    alter table(:organization_user) do
      modify :organization_id, references(:organizations, on_delete: :delete_all)
    end

    execute "ALTER TABLE organization_user DROP FOREIGN KEY organization_user_user_id_fkey"
    alter table(:organization_user) do
      modify :user_id, references(:users, on_delete: :delete_all)
    end

    # Organizations Table
    execute "ALTER TABLE organizations DROP FOREIGN KEY organizations_default_payment_fkey"
    alter table(:organizations) do
      modify :default_payment_id, references(:cards, on_delete: :nilify_all)
    end

    # Retrospective/Participants Join Table
    execute "ALTER TABLE retrospective_participants DROP FOREIGN KEY retrospective_participants_retrospective_id_fkey"
    alter table(:retrospective_participants) do
      modify :retrospective_id, references(:retrospectives, on_delete: :delete_all)
    end
    
    execute "ALTER TABLE retrospective_participants DROP FOREIGN KEY retrospective_participants_user_id_fkey"
    alter table(:retrospective_participants) do
      modify :user_id, references(:users, on_delete: :delete_all)
    end

    # Retrospectives Table
    execute "ALTER TABLE retrospectives DROP FOREIGN KEY retrospectives_moderator_id_fkey"
    alter table(:retrospectives) do
      modify :moderator_id, references(:users, on_delete: :nilify_all)
    end
    
    execute "ALTER TABLE retrospectives DROP FOREIGN KEY retrospectives_team_id_fkey"
    alter table(:retrospectives) do
      modify :team_id, references(:teams, on_delete: :delete_all)
    end

    execute "ALTER TABLE retrospectives DROP FOREIGN KEY retrospectives_type_id_fkey"
    alter table(:retrospectives) do
      modify :type_id, references(:retrospective_types, on_delete: :nilify_all)
    end

    # Sprint Scores Table
    execute "ALTER TABLE sprint_scores DROP FOREIGN KEY sprint_scores_retrospective_id_fkey"
    alter table(:sprint_scores) do
      modify :retrospective_id, references(:retrospectives, on_delete: :delete_all)
    end
    
    execute "ALTER TABLE sprint_scores DROP FOREIGN KEY sprint_scores_user_id_fkey"
    alter table(:sprint_scores) do
      modify :user_id, references(:users, on_delete: :nilify_all)
    end
    
    # Team/Admins Join Table
    execute "ALTER TABLE team_admin DROP FOREIGN KEY team_admin_admin_id_fkey"
    alter table(:team_admin) do
      modify :user_id, references(:users, on_delete: :delete_all)
    end
    
    execute "ALTER TABLE team_admin DROP FOREIGN KEY team_admin_team_id_fkey"
    alter table(:team_admin) do
      modify :team_id, references(:teams, on_delete: :delete_all)
    end

    # Teams Table
    execute "ALTER TABLE teams DROP FOREIGN KEY teams_organization_id_fkey"
    alter table(:teams) do
      modify :organization_id, references(:organizations, on_delete: :nilify_all)
    end

    # User/Teams Join Table
    execute "ALTER TABLE user_team DROP FOREIGN KEY user_team_team_id_fkey"
    alter table(:user_team) do
      modify :team_id, references(:teams, on_delete: :delete_all)
    end

    execute "ALTER TABLE user_team DROP FOREIGN KEY user_team_user_id_fkey"
    alter table(:user_team) do
      modify :user_id, references(:users, on_delete: :delete_all)
    end
  end

  def down do
    # Cards Table
    execute "ALTER TABLE cards DROP FOREIGN KEY cards_organization_id_fkey"
    alter table(:cards) do
      modify :organization_id, references(:organizations, on_delete: :nothing)
    end

    # Feedbacks Table
    execute "ALTER TABLE feedbacks DROP FOREIGN KEY feedbacks_retrospective_id_fkey"
    alter table(:feedbacks) do
      modify :retrospective_id, references(:retrospectives, on_delete: :nothing)
    end
    
    execute "ALTER TABLE feedbacks DROP FOREIGN KEY feedbacks_user_id_fkey"
    alter table(:feedbacks) do
      modify :user_id, references(:users, on_delete: :nothing)
    end

    # Member Delegates Table
    execute "ALTER TABLE member_delegate DROP FOREIGN KEY member_delegate_team_id_fkey"
    alter table(:member_delegate) do
      modify :team_id, references(:teams, on_delete: :nothing)
    end

    # Organization/Admin Join Table
    execute "ALTER TABLE organization_admin DROP FOREIGN KEY organization_admin_organization_id_fkey"
    alter table(:organization_admin) do
      modify :organization_id, references(:organizations, on_delete: :nothing)
    end

    execute "ALTER TABLE organization_admin DROP FOREIGN KEY organization_admin_user_id_fkey"
    alter table(:organization_admin) do
      modify :user_id, references(:users, on_delete: :nothing)
    end

    # Organization/User Join Table
    execute "ALTER TABLE organization_user DROP FOREIGN KEY organization_user_organization_id_fkey"
    alter table(:organization_user) do
      modify :organization_id, references(:organizations, on_delete: :nothing)
    end

    execute "ALTER TABLE organization_admin DROP FOREIGN KEY organization_user_user_id_fkey"
    alter table(:organization_user) do
      modify :user_id, references(:users, on_delete: :nothing)
    end

    # Organizations Table
    execute "ALTER TABLE organizations DROP FOREIGN KEY organizations_default_payment_fkey"
    alter table(:organizations) do
      modify :default_payment_id, references(:cards, on_delete: :nothing)
    end

    # Retrospective/Participants Join Table
    execute "ALTER TABLE retrospective_participants DROP FOREIGN KEY retrospective_participants_retrospective_id_fkey"
    alter table(:retrospective_participants) do
      modify :retrospective_id, references(:retrospectives, on_delete: :nothing)
    end
    
    execute "ALTER TABLE retrospective_participants DROP FOREIGN KEY retrospective_participants_user_id_fkey"
    alter table(:retrospective_participants) do
      modify :user_id, references(:users, on_delete: :nothing)
    end

    # Retrospectives Table
    execute "ALTER TABLE retrospectives DROP FOREIGN KEY retrospectives_moderator_id_fkey"
    alter table(:retrospectives) do
      modify :moderator_id, references(:users, on_delete: :nothing)
    end
    
    execute "ALTER TABLE retrospectives DROP FOREIGN KEY retrospectives_team_id_fkey"
    alter table(:retrospectives) do
      modify :team_id, references(:teams, on_delete: :nothing)
    end

    execute "ALTER TABLE retrospectives DROP FOREIGN KEY retrospectives_type_id_fkey"
    alter table(:retrospectives) do
      modify :type_id, references(:retrospective_types, on_delete: :nothing)
    end

    # Sprint Scores Table
    execute "ALTER TABLE sprint_scores DROP FOREIGN KEY sprint_scores_retrospective_id_fkey"
    alter table(:sprint_scores) do
      modify :retrospective_id, references(:retrospectives, on_delete: :nothing)
    end
    
    execute "ALTER TABLE sprint_scores DROP FOREIGN KEY sprint_scores_user_id_fkey"
    alter table(:sprint_scores) do
      modify :user_id, references(:users, on_delete: :nothing)
    end
    
    # Team/Admins Join Table
    execute "ALTER TABLE team_admin DROP FOREIGN KEY team_admin_admin_id_fkey"
    alter table(:team_admin) do
      modify :user_id, references(:users, on_delete: :nothing)
    end
    
    execute "ALTER TABLE team_admin DROP FOREIGN KEY team_admin_team_id_fkey"
    alter table(:team_admin) do
      modify :team_id, references(:teams, on_delete: :nothing)
    end

    # Teams Table
    execute "ALTER TABLE teams DROP FOREIGN KEY teams_organization_id_fkey"
    alter table(:teams) do
      modify :organization_id, references(:organizations, on_delete: :nothing)
    end

    # User/Teams Join Table
    execute "ALTER TABLE user_team DROP FOREIGN KEY user_team_team_id_fkey"
    alter table(:user_team) do
      modify :team_id, references(:teams, on_delete: :nothing)
    end

    execute "ALTER TABLE user_team DROP FOREIGN KEY user_team_user_id_fkey"
    alter table(:user_team) do
      modify :user_id, references(:users, on_delete: :nothing)
    end
  end
end
