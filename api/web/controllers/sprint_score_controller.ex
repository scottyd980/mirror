defmodule Mirror.SprintScoreController do
  use Mirror.Web, :controller

  alias Mirror.User
  alias Mirror.Retrospective
  alias Mirror.UserHelper
  alias Mirror.SprintScore

  import Logger

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "scores"}}) do

    current_user = Guardian.Plug.current_resource(conn)

    # TODO: need to handle making sure user is retro/team member

    changeset = SprintScore.changeset %SprintScore{}, %{
        score: attributes["score"],
        user_id: relationships["user"]["data"]["id"],
        retrospective_id: relationships["retrospective"]["data"]["id"]
    }

    case Repo.insert changeset do
        {:ok, score} ->
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
    |> Repo.preload([:user, :retrospective])

    retrospective = score.retrospective
    |> Repo.preload([:team])

    team = retrospective.team
    |> Repo.preload([:members])

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
