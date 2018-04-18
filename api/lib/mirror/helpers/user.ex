defmodule Mirror.Helpers.User do
    alias Mirror.Repo
  
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
      |> Repo.preload([:moderator, :team])
  
      team = retro.team
  
      retro.moderator == user and user_is_team_member?(user, team)
    end
  
    def user_is_organization_admin?(user, organization) do
      organization = organization
      |> Repo.preload([:admins])
  
      Enum.member?(organization.admins, user)
    end
  end
  