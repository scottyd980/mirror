defmodule Mirror.UserHelper do
  alias Mirror.Repo
  alias Mirror.Team
  alias Mirror.Retrospective

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

  def user_is_participant?(user, retrospective) do
    retro = Repo.get!(Retrospective, retrospective.id)
    |> Repo.preload([:participants])

    Enum.member?(retro.participants, user)
  end
end
