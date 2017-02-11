defmodule Mirror.SprintScoreController do
  use Mirror.Web, :controller

  alias Mirror.{User, Retrospective, UserHelper, SprintScore, Team}

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "scores"}}) do

    current_user = Guardian.Plug.current_resource(conn)

    retrospective_id = relationships["retrospective"]["data"]["id"]
    user_id = relationships["user"]["data"]["id"]

    # TODO: need to handle making sure user is retro/team member
    # Also need to make sure that the user hasn't alreadt submitted a score

    changeset = SprintScore.changeset %SprintScore{}, %{
        score: attributes["score"],
        user_id: user_id,
        retrospective_id: retrospective_id
    }

    case Repo.insert changeset do
        {:ok, score} ->
            Mirror.Endpoint.broadcast("retrospective:#{retrospective_id}", "sprint_score_added", Mirror.SprintScoreView.render("show.json", score: score))

            conn
            |> put_status(:created)
            |> render(Mirror.SprintScoreView, "show.json", score: score)
        {:error, changeset} ->
            use_error_view(conn, 422, changeset)
    end

  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    score = Repo.get!(SprintScore, id)
    |> SprintScore.preload_relationships()

    retrospective = score.retrospective
    |> Retrospective.preload_relationships()

    team = retrospective.team
    |> Team.preload_relationships()

    case UserHelper.user_is_team_member?(current_user, team) do
      true ->
        render(conn, "show.json", score: score)
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
