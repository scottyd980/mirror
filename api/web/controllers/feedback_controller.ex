defmodule Mirror.FeedbackController do
  use Mirror.Web, :controller

  alias Mirror.User
  alias Mirror.Retrospective
  alias Mirror.UserHelper
  alias Mirror.Feedback
  alias Mirror.Team

  import Logger

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "feedbacks"}}) do

    current_user = Guardian.Plug.current_resource(conn)

    retrospective_id = relationships["retrospective"]["data"]["id"]
    user_id = relationships["user"]["data"]["id"]

    # TODO: need to handle making sure user is retro/team member
    # Also need to make sure that the user hasn't alreadt submitted feedback

    changeset = Feedback.changeset %Feedback{}, %{
        message: attributes["message"],
        state: 0,
        type: attributes["type"],
        user_id: user_id,
        retrospective_id: retrospective_id
    }

    case Repo.insert changeset do
        {:ok, feedback} ->
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

  defp use_error_view(conn, status, changeset) do
    conn
    |> put_status(status)
    |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  end
end
