defmodule MirrorWeb.RetrospectiveController do
  use MirrorWeb, :controller

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.Retrospective
  alias Mirror.Teams

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def index(conn, params) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)
    team = Teams.get_team!(params["filter"]["team"])

    case Helpers.User.user_is_team_member?(current_user, team) do
      true ->
        retrospectives = Retrospectives.list_retrospectives(team)
        render(conn, "index.json-api", data: retrospectives)
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json-api")
    end
  end

  def create(conn, %{"data" => data}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)
    retrospective_params = JaSerializer.Params.to_attributes(data)
    retrospective_params = Map.put(retrospective_params, "moderator_id", current_user.id)
    team = Teams.get_team!(retrospective_params["team_id"])
    retrospective_params = Map.put(retrospective_params, "team_id", team.id)

    case Helpers.User.user_is_team_member?(current_user, team) do
      true ->
        with {:ok, %Retrospective{} = retrospective} <- Retrospectives.create_retrospective(retrospective_params) do
          # WS BROADCAST
          MirrorWeb.Endpoint.broadcast("team:#{retrospective.team.uuid}", "retrospective_in_progress", %{retrospective_in_progress: true, retrospective_id: retrospective.id})

          conn
          |> put_status(:created)
          |> render("show.json-api", data: retrospective |> Retrospective.preload_relationships)
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
        end
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json-api")
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    retrospective = Retrospectives.get_retrospective!(id)
    |> Retrospective.preload_relationships

    case Helpers.User.user_is_team_member?(current_user, retrospective.team) do
      true ->
        render(conn, "show.json-api", data: retrospective |> Retrospective.preload_relationships)
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json-api")
    end
  end

  def update(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    retrospective_params = JaSerializer.Params.to_attributes(conn.body_params)

    retrospective = Retrospectives.get_retrospective!(id)
    |> Retrospective.preload_relationships

    case Helpers.User.user_is_team_admin?(current_user, retrospective.team) || Helpers.User.user_is_moderator?(current_user, retrospective) do
      true ->
        with {:ok, %Retrospective{} = retrospective} <- Retrospectives.update_retrospective(retrospective, retrospective_params) 
        do
          MirrorWeb.Endpoint.broadcast("retrospective:#{retrospective.id}", "retrospective_update", MirrorWeb.RetrospectiveView.render("show.json", data: retrospective |> Retrospective.preload_relationships))
          render(conn, "show.json-api", data: retrospective |> Retrospective.preload_relationships)
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
        end
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json-api")
    end
  end

  # TODO: Not sure this is necessary
  # def delete(conn, %{"id" => id}) do
  #   current_user = Mirror.Guardian.Plug.current_resource(conn)

  #   retrospective = Retrospectives.get_retrospective!(id)
  #   |> Retrospective.preload_relationships

  #   case Helpers.User.user_is_team_member?(current_user, retrospective.team) do
  #     true ->
  #       with {:ok, %Retrospective{}} <- Retrospectives.delete_retrospective(retrospective)
  #       do
  #         render(conn, "delete.json")
  #       else
  #         {:error, changeset} ->
  #           conn
  #           |> put_status(:unprocessable_entity)
  #           |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
  #       end
  #     _ ->
  #       conn
  #       |> put_status(404)
  #       |> render(Mirror.ErrorView, "404.json-api")
  #   end
  # end
end
