defmodule Mirror.RetrospectiveController do
  use Mirror.Web, :controller

  alias Mirror.{Team, Retrospective, UserHelper, RetrospectiveUser, TeamChannel}

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def index(conn, params) do
    current_user = Guardian.Plug.current_resource(conn)

    team = Repo.get_by!(Team, uuid: params["filter"]["team"])

    cond do
      UserHelper.user_is_team_member?(current_user, team) ->
        query = from r in Retrospective,
                where: r.team_id == ^team.id,
                where: r.cancelled == false
        retrospectives = Repo.all(query)
        |> Retrospective.preload_relationships()
        render(conn, "index.json", retrospectives: retrospectives)
      true ->
        use_error_view(conn, 401, %{})
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    retrospective = Repo.get!(Retrospective, id)
    |> Retrospective.preload_relationships()

    team = retrospective.team
    |> Team.preload_relationships()

    case Enum.member?(team.members, current_user) do
      true ->
        render(conn, "show.json", retrospective: retrospective)
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json")
    end
  end

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "retrospectives"}}) do

    current_user = Guardian.Plug.current_resource(conn)
    team = Repo.get_by!(Team, uuid: relationships["team"]["data"]["id"])

    params = %{"attributes" => attributes, "participants" => relationships["participants"], "moderator" => relationships["moderator"], "team" => team}

    case Retrospective.create(params, current_user) do
      {:ok, retrospective} ->
        Mirror.Endpoint.broadcast("team:#{retrospective.team.uuid}", "retrospective_in_progress", %{retrospective_in_progress: true, retrospective_id: retrospective.id})

        conn
        |> put_status(:created)
        |> render("show.json", retrospective: retrospective)
      {:error, :unauthorized} ->
        use_error_view(conn, 401, %{})
      {:error, :forbidden} ->
        use_error_view(conn, 403, %{})
      {:error, changeset} ->
        use_error_view(conn, :unprocessable_entity, changeset)
    end
  end

  def update(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    body_params = conn.body_params
    
    retrospective = Repo.get!(Retrospective, id)
    |> Retrospective.preload_relationships()

    case UserHelper.user_is_team_admin?(current_user, retrospective.team) || UserHelper.user_is_moderator?(current_user, retrospective) do
      true ->
        state = body_params["data"]["attributes"]["state"]
        cancelled = body_params["data"]["attributes"]["cancelled"]

        changeset = Retrospective.changeset(retrospective, %{state: state, cancelled: cancelled})
      
        case Repo.update(changeset) do
          {:ok, retrospective} ->
            Mirror.Endpoint.broadcast("retrospective:#{retrospective.id}", "retrospective_update", Mirror.RetrospectiveView.render("show.json", retrospective: retrospective))
            render(conn, "show.json", retrospective: retrospective)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
        end
      _ ->
        use_error_view(conn, :unprocessable_entity, %{})
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    retro = Repo.get!(Retrospective, id)
    |> Retrospective.preload_relationships
  
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    case UserHelper.user_is_team_member?(current_user, retro.team) do
      true ->
        Repo.delete!(retro)
        render(conn, "delete.json")
      _ ->
        use_error_view(conn, :unprocessable_entity, %{})
    end
  end

  defp use_error_view(conn, status, changeset) do
    conn
    |> put_status(status)
    |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  end
end
