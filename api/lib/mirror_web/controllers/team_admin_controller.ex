defmodule MirrorWeb.TeamAdminController do
  use MirrorWeb, :controller

  alias Mirror.Teams
  alias Mirror.Teams.Admin
  alias Mirror.Accounts

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def create(conn, %{"admin_id" => admin_id, "team_id" => team_id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    team = Teams.get_team!(team_id)
    user = Accounts.get_user!(admin_id)

    case Helpers.User.user_is_team_admin?(current_user, team) && Helpers.User.user_is_team_member?(user, team) do
      true ->
        with {:ok, %Admin{} = admin} <- Teams.create_admin(%{team_id: team.id, user_id: admin_id}) 
        do
          conn
          |> put_status(:created)
          |> render("show.json-api", data: admin |> Admin.preload_relationships)
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
        end
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end

  def delete(conn, %{"admin_id" => admin_id, "team_id" => team_id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    team = Teams.get_team!(team_id)
    user = Accounts.get_user!(admin_id)

    case Helpers.User.user_is_team_admin?(current_user, team) && Helpers.User.user_is_team_member?(user, team) do
      true ->
        with {:ok, _} <- Teams.delete_admin(%{team_id: team.id, user_id: admin_id}) 
        do
          conn
          |> put_status(:ok)
          |> render("delete.json-api")
        else 
          {:error, :no_additional_admins} ->
            conn
            |> put_status(403)
            |> render(MirrorWeb.ErrorView, "403.json-api")
          {:error, _} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: %{})
        end
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end
end
