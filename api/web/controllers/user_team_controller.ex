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

    case user_is_member?(member_delegate.team, current_user) do
      false ->
        handle_new_member(conn, current_user, member_delegate)
      _ ->
        handle_existing_member(conn, %{user_id: current_user.id, team_id: member_delegate.team.id})
    end

  end

  defp user_is_member?(team, user) do
    team = Repo.get!(Team, team.id)
    |> Repo.preload([:admins, :members])

    Enum.member?(team.members, user)
  end

  defp mark_delegate_used(conn, member_delegate) do
    changeset = MemberDelegate.changeset member_delegate, %{is_accessed: true}
    Repo.update! changeset

    conn
  end

  defp handle_existing_member(conn, user_team) do
    conn
    |> put_status(:ok)
    |> render(Mirror.UserTeamView, "show.json", user_team: user_team)
  end

  defp handle_new_member(conn, current_user, member_delegate) do

    changeset = UserTeam.changeset %UserTeam{}, %{
      user_id: current_user.id,
      team_id: member_delegate.team.id
    }

    case Repo.insert changeset do
      {:ok, user_team} ->
        conn
        |> mark_delegate_used(member_delegate)
        |> put_status(:created)
        |> render(Mirror.UserTeamView, "show.json", user_team: user_team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end

  end
end
