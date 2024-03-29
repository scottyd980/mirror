defmodule MirrorWeb.TeamController do
  use MirrorWeb, :controller

  alias Mirror.{Teams, Organizations}
  alias Mirror.Teams.Team

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def create(conn, %{"data" => data}) do
    team_members = [Mirror.Guardian.Plug.current_resource(conn)]
    team_admins = [Mirror.Guardian.Plug.current_resource(conn)]
    team_params = JaSerializer.Params.to_attributes(data)
    team_member_delegates = team_params["member_delegates"]

    with {:ok, %Team{} = team} <- Teams.create_team(team_params, team_admins, team_members, team_member_delegates) do
      conn
      |> put_status(:created)
      |> render("show.json-api", data: team |> Team.preload_relationships)
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: %{})
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    team = Teams.get_team!(id)
    |> Team.preload_relationships()

    case Helpers.User.user_is_team_member?(current_user, team) do
      true ->
        render(conn, "show.json-api", data: team |> Team.preload_relationships)
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end

  def update(conn, %{"id" => id, "data" => data}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    team_params = JaSerializer.Params.to_attributes(data)

    team = Teams.get_team!(id)
  
    organization_id = team_params["organization_id"]

    organization = case organization_id do
      nil -> nil
      org_id -> Organizations.get_organization!(org_id)
    end

    team_params = case organization do
      nil -> team_params
      _ -> Map.put(team_params, "organization_id", organization.id)
    end

    case Helpers.User.user_is_team_admin?(current_user, team) && (
          organization == nil || 
          team.organization_id == organization_id || 
          Helpers.User.user_is_organization_admin?(current_user, organization)
        ) 
    do
      true ->
        with {:ok, %Team{} = team} <- Teams.update_team(team, team_params) do
          render(conn, "show.json-api", data: team |> Team.preload_relationships)
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

  def delete(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    team = Teams.get_team!(id)

    case Helpers.User.user_is_team_admin?(current_user, team) do
      true ->
        with {:ok, %Team{}} <- Teams.delete_team(team) do
          conn
          |> put_status(:ok)
          |> render("delete.json-api")
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json", changeset: changeset)
        end
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end

  def find_next_sprint(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    team = Teams.get_team!(id)

    case Helpers.User.user_is_team_member?(current_user, team) do
      true ->
        next_sprint = Team.find_next_retrospective(team)
        render(conn, "next_sprint.json-api", %{next_sprint: next_sprint, team: team})
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end
end
