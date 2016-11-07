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

    case user_is_member?(current_user, member_delegate.team) do
      false ->
        handle_add_new_member(conn, current_user, member_delegate)
      _ ->
        handle_add_existing_member(conn, %{user_id: current_user.id, team_id: member_delegate.team.id})
    end

  end

  def delete(conn, %{"user_id" => user_id, "team_id" => team_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    team = Repo.get!(Team, team_id)
    user = Repo.get!(User, user_id)

    cond do
      user_is_member?(user, team) ->
        handle_remove_member(conn, %{user_id: user_id, team_id: team_id})
      user_is_admin?(user, team) ->
        handle_remove_member(conn, %{user_id: user_id, team_id: team_id})
      true ->
        unprocessable_response(conn, %{})
    end
  end

  defp user_is_member?(user, team) do
    team = Repo.get!(Team, team.id)
    |> Repo.preload([:admins, :members])

    Enum.member?(team.members, user)
  end

  defp user_is_admin?(user, team) do
    team = Repo.get!(Team, team.id)
    |> Repo.preload([:admins, :members])

    Enum.member?(team.admins, user)
  end

  defp mark_delegate_used(conn, member_delegate) do
    changeset = MemberDelegate.changeset member_delegate, %{is_accessed: true}
    Repo.update! changeset

    conn
  end

  defp handle_add_existing_member(conn, user_team) do
    conn
    |> put_status(:ok)
    |> render(Mirror.UserTeamView, "show.json", user_team: user_team)
  end

  defp handle_add_new_member(conn, current_user, member_delegate) do

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
        unprocessable_response(conn, changeset)
    end

  end

  defp handle_remove_member(conn, user_team) do
    case Repo.delete_all(from u in UserTeam, where: u.user_id == ^user_team.user_id and u.team_id == ^user_team.team_id) do
      {:error, _} ->
        unprocessable_response(conn, %{})
      {_, _} ->
        conn
        |> put_status(:ok)
        |> render(Mirror.UserTeamView, "delete.json", user_team: user_team)
    end
  end

  defp unprocessable_response(conn, changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  end
end
