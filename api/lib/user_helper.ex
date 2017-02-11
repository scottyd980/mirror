defmodule Mirror.UserHelper do
  alias Mirror.Repo
  alias Mirror.Team
  alias Mirror.Retrospective

  def user_is_team_member?(user, team) do
    team = team
    |> Repo.preload([:members])

    Enum.member?(team.members, user)
  end

  def user_is_team_admin?(user, team) do
    team = team
    |> Repo.preload([:admins])

    Enum.member?(team.admins, user)
  end

  def user_is_participant?(user, retrospective) do
    retro = retrospective
    |> Repo.preload([:participants])

    Enum.member?(retro.participants, user)
  end

  def user_is_moderator?(user, retrospective) do
    retro = retrospective
    |> Repo.preload([:moderator])

    retro.moderator == user
  end
end
