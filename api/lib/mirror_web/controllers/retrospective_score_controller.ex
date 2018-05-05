defmodule MirrorWeb.RetrospectiveScoreController do
  use MirrorWeb, :controller

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.{Retrospective, Score}
  alias Mirror.Teams

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def create(conn, %{"data" => data}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)
    score_params = JaSerializer.Params.to_attributes(data)
    score_params = Map.put(score_params, "user_id", current_user.id)

    retrospective = Retrospectives.get_retrospective!(score_params["retrospective_id"])
    |> Retrospective.preload_relationships

    team = retrospective.team

    case Helpers.User.user_is_team_member?(current_user, team) do
      true ->
        with {:ok, %Score{} = score} <- Retrospectives.create_score(score_params) do
          # WS BROADCAST
          MirrorWeb.Endpoint.broadcast("retrospective:#{score_params["retrospective_id"]}", "sprint_score_added", MirrorWeb.RetrospectiveScoreView.render("show.json-api", data: score |> Score.preload_relationships))

          conn
          |> put_status(:created)
          |> render("show.json-api", data: score |> Score.preload_relationships)
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

    score = Retrospectives.get_score!(id)
    |> Score.preload_relationships

    retrospective = score.retrospective
    |> Retrospective.preload_relationships()

    case Helpers.User.user_is_team_member?(current_user, retrospective.team) do
      true ->
        render(conn, "show.json-api", data: score |> Score.preload_relationships)
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end
end
