defmodule Mirror.RetrospectiveController do
  use Mirror.Web, :controller

  alias Mirror.{Team, Retrospective, UserHelper, RetrospectiveUser, TeamChannel}

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def index(conn, _params) do
    retrospectives = Repo.all(Retrospective)
    |> Retrospective.preload_relationships()
    render(conn, "index.json", retrospectives: retrospectives)
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
    team = Repo.get!(Team, relationships["team"]["data"]["id"])

    params = %{"attributes" => attributes, "participants" => relationships["participants"], "moderator" => relationships["moderator"], "team" => relationships["team"]}

    cond do
      UserHelper.user_is_team_member?(current_user, team) ->
        case create_retrospective(params) do
          {:ok, retrospective} ->
            Mirror.Endpoint.broadcast("team:#{retrospective.team.id}", "retrospective_in_progress", %{retrospective_in_progress: true, retrospective_id: retrospective.id})

            conn
            |> put_status(:created)
            |> render("show.json", retrospective: retrospective)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
        end
      true ->
        use_error_view(conn, 401, %{})
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    team = Repo.get!(Team, id)
    |> Team.preload_relationships()

    case Enum.member?(team.members, current_user) do
      true ->
        render(conn, "show.json", team: team)
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json")
    end
  end

  defp create_retrospective(params) do
    Repo.transaction fn ->
      with {:ok, retrospective} <- insert_retrospective(params),
           [{:ok, retrospective_participants}] <- add_retrospective_participants(retrospective, params["participants"]) do
             retrospective
             |> Retrospective.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
      end
    end
  end

  defp insert_retrospective(params) do
    %Retrospective{}
    |> Retrospective.changeset(%{
        name: params["attributes"]["name"],
        isAnonymous: params["attributes"]["is-anonymous"],
        state: params["attributes"]["state"],
        moderator_id: params["moderator"]["data"]["id"],
        team_id: params["team"]["data"]["id"],
        type_id: params["attributes"]["type"]
      })
    |> Repo.insert
  end

  defp add_retrospective_participants(retrospective, participants) do
    cond do
      length(participants["data"]) > 0 ->
        Enum.map participants["data"], fn participant ->
          %RetrospectiveUser{}
          |> RetrospectiveUser.changeset(%{user_id: participant.id, retrospective_id: retrospective.id})
          |> Repo.insert
        end
      true ->
        [{:ok, nil}]
    end
  end

  def update(conn, %{"id" => id}) do
    body_params = conn.body_params
    
    retrospective = Repo.get!(Retrospective, id)
    |> Retrospective.preload_relationships()

    state = body_params["data"]["attributes"]["state"];

    changeset = Retrospective.changeset(retrospective, %{state: state})
  
    case Repo.update(changeset) do
      {:ok, retrospective} ->
        Mirror.Endpoint.broadcast("retrospective:#{retrospective.id}", "retrospective_state_change", Mirror.RetrospectiveView.render("show.json", retrospective: retrospective))
        render(conn, "show.json", retrospective: retrospective)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
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
