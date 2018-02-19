defmodule Mirror.FeedbackController do
  use Mirror.Web, :controller

  require Logger

  alias Mirror.{User, Retrospective, UserHelper, Feedback, Team}

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  # TODO: Make sure current_user is a member of the team
  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "feedbacks"}}) do
    current_user = Guardian.Plug.current_resource(conn)

    retrospective_id = relationships["retrospective"]["data"]["id"]
    user_id = relationships["user"]["data"]["id"]

    changeset = Feedback.changeset %Feedback{}, %{
        message: attributes["message"],
        state: 0,
        type: attributes["type"],
        user_id: current_user.id,
        retrospective_id: retrospective_id
    }

    case Repo.insert changeset do
        {:ok, feedback} ->
            feedback = feedback
            |> Feedback.preload_relationships

            Mirror.Endpoint.broadcast("retrospective:#{retrospective_id}", "feedback_added", Mirror.FeedbackView.render("show.json", feedback: feedback))

            conn
            |> put_status(:created)
            |> render(Mirror.FeedbackView, "show.json", feedback: feedback)
        {:error, changeset} ->
            use_error_view(conn, 422, changeset)
    end

  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    feedback = Repo.get!(Feedback, id)
    |> Feedback.preload_relationships()

    retrospective = feedback.retrospective
    |> Retrospective.preload_relationships()

    team = retrospective.team
    |> Team.preload_relationships()

    case UserHelper.user_is_team_member?(current_user, team) do
      true ->
        render(conn, "show.json", feedback: feedback)
      _ ->
        use_error_view(conn, 401, %{})
    end
  end

  # TODO: Need to make sure this is a moderator of the retrospective making changes
  def update(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    body_params = conn.body_params
    
    feedback = Repo.get!(Feedback, id)
    |> Feedback.preload_relationships()

    state = body_params["data"]["attributes"]["state"];

    changeset = Feedback.moderator_changeset(feedback, current_user, %{state: state})
  
    case Repo.update(changeset) do
      {:ok, feedback} ->
        Mirror.Endpoint.broadcast("retrospective:#{feedback.retrospective.id}", "feedback_state_change", Mirror.FeedbackView.render("show.json", feedback: feedback))
        render(conn, "show.json", feedback: feedback)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end
  end

  defp use_error_view(conn, status, changeset) do
    conn
    |> put_status(status)
    |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  end
end
