defmodule Mirror.TeamAdminController do
  use Mirror.Web, :controller

  alias Mirror.User
  alias Mirror.Team
  alias Mirror.UserTeam
  alias Mirror.TeamAdmin

  import Logger

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def create(conn, %{"admin_id" => admin_id, "team_id" => team_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    team = Repo.get!(Team, team_id)
    user = Repo.get!(User, admin_id)

    cond do
      user_is_admin?(current_user, team) ->
        handle_add_admin(conn, user, team)
      true ->
        use_error_view(conn, 401, %{})
    end

  end

  def delete(conn, %{"admin_id" => admin_id, "team_id" => team_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    team = Repo.get!(Team, team_id)
    user = Repo.get!(User, admin_id)

    cond do
      user_is_admin?(current_user, team) ->
        handle_remove_admin(%{user: user, team: team})
      true ->
        use_error_view(conn, 401, %{})
    end

  end

  defp remove_member(conn, user, team) do
    cond do
      user_is_admin?(current_user, team) ->
        case handle_remove_admin_member(%{user: user, team: team}) do
          {:ok, {1, 1}} ->
            conn
            |> put_status(:ok)
            |> render(Mirror.UserTeamView, "delete.json", user_team: %{user_id: user.id, team_id: team.id})
          {:error, "No other admins"} ->
            use_error_view(conn, :forbidden, %{})
          {:error, "Unexpected error"} ->
            use_error_view(conn, 500, %{})
          {:error, changeset} ->
            use_error_view(conn, :unprocessable_entity, changeset)
        end
      user_is_member?(user, team) ->
        case handle_remove_member(%{user: user, team: team}) do
          {:ok, affected_rows} ->
            conn
            |> put_status(:ok)
            |> render(Mirror.UserTeamView, "delete.json", user_team: %{user_id: user.id, team_id: team.id})
          {:error, _} ->
            use_error_view(conn, 422, %{})
        end
      true ->
        use_error_view(conn, 422, %{})
    end
  end

  defp user_is_admin?(user, team) do
    team = Repo.get!(Team, team.id)
    |> Repo.preload([:admins, :members])

    Enum.member?(team.admins, user)
  end

  defp handle_add_admin(conn, user, team) do
    changeset = TeamAdmin.changeset %TeamAdmin{}, %{
      user_id: user.id,
      team_id: team.id
    }

    case Repo.insert changeset do
      {:ok, team_admin} ->
        conn
        |> put_status(:created)
        |> render(Mirror.TeamAdminView, "show.json", team_admin: team_admin)
      {:error, changeset} ->
        use_error_view(conn, 422, changeset)
    end
  end

  defp handle_remove_admin(user_team) do
    case Repo.delete_all(from u in TeamAdmin, where: u.user_id == ^user_team.user.id and u.team_id == ^user_team.team.id) do
      {:error, _} ->
        {:error, "Problem deleting rows"}
      {affected_rows, _} ->
        {:ok, affected_rows}
    end
  end

  defp use_error_view(conn, status, changeset) do
    conn
    |> put_status(status)
    |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  end
end
