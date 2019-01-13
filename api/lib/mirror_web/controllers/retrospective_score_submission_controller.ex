defmodule MirrorWeb.RetrospectiveScoreSubmissionController do
  use MirrorWeb, :controller

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.{Retrospective, ScoreSubmission}

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def show(conn, %{"id" => id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    score_submission = Retrospectives.get_score_submission!(id)
    |> ScoreSubmission.preload_relationships

    retrospective = score_submission.retrospective
    |> Retrospective.preload_relationships()

    case Helpers.User.user_is_team_member?(current_user, retrospective.team) do
      true ->
        render(conn, "show.json-api", data: score_submission)
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end
end
