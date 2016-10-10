defmodule Mirror.TeamController do
  use Mirror.Web, :controller

  alias Mirror.Team

  import Logger

  def index(conn, _params) do
    teams = Repo.all(Team)
    |> Repo.preload([:admin])
    render(conn, "index.json", teams: teams)
  end

  def create(conn, %{"data" => %{"type" => "teams",
    "attributes" => %{
      "name" => name,
      "is-anonymous" => isAnonymous,
      "avatar" => avatar,
      "admin" => admin}}}) do

    changeset = %Team{}
      |> Team.changeset(%{name: name, isAnonymous: isAnonymous, avatar: avatar})
      |> Ecto.Changeset.put_assoc(:admin, Repo.get(Mirror.User, admin))

     # Logger.info changeset
    case Repo.insert(changeset) do
      {:ok, team} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", team_path(conn, :show, team))
        |> render("show.json", team: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)
    |> Repo.preload([:admin])
    render(conn, "show.json", team: team)
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Repo.get!(Team, id)
    changeset = Team.changeset(team, team_params)

    case Repo.update(changeset) do
      {:ok, team} ->
        render(conn, "show.json", team: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(team)

    send_resp(conn, :no_content, "")
  end
end
