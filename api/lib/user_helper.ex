defmodule Mirror.UserHelper do
  alias Mirror.Repo
  alias Mirror.Team

  def user_is_team_member?(user, team) do
    team = Repo.get!(Team, team.id)
    |> Repo.preload([:admins, :members])

    Enum.member?(team.members, user)
  end

  def user_is_team_admin?(user, team) do
    team = Repo.get!(Team, team.id)
    |> Repo.preload([:admins, :members])

    Enum.member?(team.admins, user)
  end
end
