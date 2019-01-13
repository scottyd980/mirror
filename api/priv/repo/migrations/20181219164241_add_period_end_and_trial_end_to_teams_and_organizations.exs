defmodule Mirror.Repo.Migrations.AddPeriodEndAndTrialEndToTeamsAndOrganizations do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :trial_end, :bigint
      add :period_end, :bigint
    end

    alter table(:organizations) do
      add :trial_end, :bigint
      add :period_end, :bigint
    end
  end
end
