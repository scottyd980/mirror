defmodule MirrorWeb.RetrospectiveActionController do
  use MirrorWeb, :controller

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.{Retrospective, Action}

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def create(conn, %{"data" => data}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)
    action_params = JaSerializer.Params.to_attributes(data)
    action_params = Map.put(action_params, "user_id", current_user.id)

    feedback = Retrospectives.get_feedback!(action_params["feedback_id"])
    
    retrospective = Retrospectives.get_retrospective!(feedback.retrospective_id)
    |> Retrospective.preload_relationships
    
    team = retrospective.team

    case Helpers.User.user_is_team_member?(current_user, team) && Helpers.User.user_is_moderator?(current_user, retrospective) do
      true ->
        with {:ok, %Action{} = action} <- Retrospectives.create_action(action_params) do
          MirrorWeb.Endpoint.broadcast("retrospective:#{retrospective.id}", "feedback_action_change", MirrorWeb.RetrospectiveActionView.render("show.json-api", data: action |> Action.preload_relationships))
          
          conn
          |> put_status(:created)
          |> render("show.json-api", data: action |> Action.preload_relationships)
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

  def show(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    action = Retrospectives.get_action!(id)

    feedback = Retrospectives.get_feedback!(action.feedback_id)
    
    retrospective = Retrospectives.get_retrospective!(feedback.retrospective_id)
    |> Retrospective.preload_relationships
    
    team = retrospective.team

    case Helpers.User.user_is_team_member?(current_user, team) do
      true ->
        render(conn, "show.json-api", data: action |> Action.preload_relationships)
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end

  def update(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)
    
    action = Retrospectives.get_action!(id)
    action_params = JaSerializer.Params.to_attributes(conn.body_params)

    feedback = Retrospectives.get_feedback!(action_params["feedback_id"])
    
    retrospective = Retrospectives.get_retrospective!(feedback.retrospective_id)
    |> Retrospective.preload_relationships

    team = retrospective.team

    case Helpers.User.user_is_team_member?(current_user, team) && Helpers.User.user_is_moderator?(current_user, retrospective) do
      true ->
        with {:ok, %Action{} = action} <- Retrospectives.update_action(action, action_params) do
          MirrorWeb.Endpoint.broadcast("retrospective:#{retrospective.id}", "feedback_action_change", MirrorWeb.RetrospectiveActionView.render("show.json-api", data: action |> Action.preload_relationships))
          render(conn, "show.json-api", data: action |> Action.preload_relationships)
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
    
    action = Retrospectives.get_action!(id)

    feedback = Retrospectives.get_feedback!(action.feedback_id)
    
    retrospective = Retrospectives.get_retrospective!(feedback.retrospective_id)
    |> Retrospective.preload_relationships

    team = retrospective.team

    case Helpers.User.user_is_team_member?(current_user, team) && Helpers.User.user_is_moderator?(current_user, retrospective) do
      true ->
        with {:ok, %Action{}} <- Retrospectives.delete_action(action) do
          conn
          |> put_status(:ok)
          |> render("delete.json-api")
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
        end
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json")
    end
  end
end
