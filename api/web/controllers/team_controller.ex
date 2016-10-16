defmodule Mirror.TeamController do
  use Mirror.Web, :controller

  alias Mirror.Team

  require Logger

  @hashconfig Hashids.new([
    salt: "?d[]?a5$~<).hU%L}0k-krUz>^[xJ@Y(yAna%`-k4Hs{^=5T6@/k]PFqkJ;FlbV+",  # using a custom salt helps producing unique cipher text
    min_len: 6,   # minimum length of the cipher text (1 by default)
  ])

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def index(conn, _params) do
    teams = Repo.all(Team)
    |> Repo.preload([:admin])
    render(conn, "index.json", teams: teams)
  end

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "teams"}}) do

    # Logger.info "#{inspect relationships}"

    team_changeset =
      %Team{}
      |> Team.changeset(%{name: attributes["name"], isAnonymous: true, avatar: "default.png"})
      |> Ecto.Changeset.put_assoc(:admin, Guardian.Plug.current_resource(conn))

    # member_changeset =

    # Repo.transaction fn ->
    #   team = Repo.insert!(team_changeset)
    #
    # end

    case Repo.insert(team_changeset) do
      {:ok, team} ->

        # Logger.info generate_unique_id team.id

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

  # Need to finish update
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

  defp generate_unique_id(team_id) do
    # System time to make it random, need to figure out how to make this work with guarantee of uniqueness
    Hashids.encode(@hashconfig, team_id + :os.system_time(:seconds))
  end
end
