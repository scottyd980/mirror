defmodule MirrorWeb.RetrospectiveFeedbackController do
  use MirrorWeb, :controller

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.{Retrospective, Feedback, FeedbackSubmission}

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def create(conn, %{"data" => data}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)
    feedback_params = JaSerializer.Params.to_attributes(data)
    feedback_params = Map.put(feedback_params, "user_id", current_user.id)

    retrospective = Retrospectives.get_retrospective!(feedback_params["retrospective_id"])
    |> Retrospective.preload_relationships

    team = retrospective.team

    case Helpers.User.user_is_team_member?(current_user, team) do
      true ->
        with {:ok, %Feedback{} = feedback} <- Retrospectives.create_feedback(feedback_params) do
          # WS BROADCAST
          case Retrospectives.create_feedback_submission(%{user_id: current_user.id, retrospective_id: retrospective.id}) do
            {:ok, feedback_submission} -> MirrorWeb.Endpoint.broadcast("retrospective:#{feedback_params["retrospective_id"]}", "feedback_submitted", MirrorWeb.RetrospectiveFeedbackSubmissionView.render("show.json-api", data: feedback_submission |> FeedbackSubmission.preload_relationships))
            _ -> :nil # Feedback was already submitted by this user, no need to re-broadcast
          end

          feedback = feedback |> Feedback.preload_relationships
          feedback = Map.put(feedback, :uuid, feedback_params["uuid"])
          MirrorWeb.Endpoint.broadcast("retrospective:#{feedback_params["retrospective_id"]}", "feedback_added", MirrorWeb.RetrospectiveFeedbackView.render("show.json-api", data: feedback))
          conn
          |> put_status(:created)
          |> render("show.json-api", data: feedback |> Feedback.preload_relationships)
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

    feedback = Retrospectives.get_feedback!(id)
    |> Feedback.preload_relationships

    retrospective = feedback.retrospective
    |> Retrospective.preload_relationships()

    case Helpers.User.user_is_team_member?(current_user, retrospective.team) do
      true ->
        render(conn, "show.json-api", data: feedback |> Feedback.preload_relationships)
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end

  def update(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    feedback_params = JaSerializer.Params.to_attributes(conn.body_params)

    feedback = Retrospectives.get_feedback!(id)
    |> Feedback.preload_relationships()

    retrospective = feedback.retrospective

    case Helpers.User.user_is_moderator?(current_user, retrospective) do
      true ->
        with {:ok, %Feedback{} = feedback} <- Retrospectives.update_feedback(feedback, feedback_params) 
        do
          MirrorWeb.Endpoint.broadcast("retrospective:#{retrospective.id}", "retrospective_update", MirrorWeb.RetrospectiveFeedbackView.render("show.json-api", data: feedback |> Feedback.preload_relationships))
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
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end
end
