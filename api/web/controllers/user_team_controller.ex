defmodule Mirror.UserTeamController do
  use Mirror.Web, :controller

  alias Mirror.User
  alias Mirror.Team
  alias Mirror.UserTeam
  alias Mirror.MemberDelegate

  import Logger

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def create(conn, %{"access-code" => access_code}) do

    current_user = Guardian.Plug.current_resource(conn)

    member_delegate = Repo.get_by!(MemberDelegate, access_code: access_code)
    |> Repo.preload([:team])

    changeset = UserTeam.changeset %UserTeam{}, %{
      user_id: current_user.id,
      team_id: member_delegate.team.id
    }

    case user_is_member(member_delegate.team, current_user) do
      false ->
        case Repo.insert changeset do
          {:ok, user_team} ->
            conn
            |> put_status(:created)
            |> render(Mirror.UserTeamView, "show.json", user_team: user_team)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
        end
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end

  end

  defp user_is_member(team, user) do
    team = Repo.get!(Team, team.id)
    |> Repo.preload([:admins, :members])

    Enum.member?(team.members, user)
  end
end
