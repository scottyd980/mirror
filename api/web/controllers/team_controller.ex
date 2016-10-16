defmodule Mirror.TeamController do
  use Mirror.Web, :controller

  alias Mirror.Team
  alias Ecto.Multi

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

    # Repo.transaction(fn ->
    #   with {:ok, team} <- create_team(conn, attributes),
    #        {:ok, updated_team} <- add_unique_id_to_team(conn, team) do
    #          conn
    #          |> put_status(:created)
    #          |> put_resp_header("location", team_path(conn, :show, updated_team))
    #          |> render("show.json", team: updated_team)
    #   else
    #     {:error, _} ->
    #       Repo.rollback
    #       conn
    #       |> put_status(:unprocessable_entity)
    #       |> render(Mirror.ChangesetView, "error.json", changeset: %{})
    #   end
    # end)

    # Repo.transaction fn ->
    #   # team = Repo.insert!(team_changeset)
    #   case Repo.insert!(team_changeset) do
    #     {:ok, team} ->
    #       team_unique_id = generate_unique_id(team.id)
    #       changeset = Team.changeset(team, %{uuid: team_unique_id})
    #
    #       case Repo.update!(changeset) do
    #         {:ok, team} ->
    #           conn
    #           |> put_status(:created)
    #           |> put_resp_header("location", team_path(conn, :show, team))
    #           |> render("show.json", team: team)
    #         {:error, changeset} ->
    #           conn
    #           |> put_status(:unprocessable_entity)
    #           |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    #       end
    #     {:error, changeset} ->
    #       conn
    #       |> put_status(:unprocessable_entity)
    #       |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    #   end
    # end
    #
    # case create_team(conn, attributes) do
    #   {:ok, team} ->
    #     case add_unique_id_to_team(conn, team) do
    #       {:ok, team} ->
    #         conn
    #         |> put_status(:created)
    #         |> put_resp_header("location", team_path(conn, :show, team))
    #         |> render("show.json", team: team)
    #       {:error, changeset} ->
    #         conn
    #         |> put_status(:unprocessable_entity)
    #         |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    #     end
    #   {:error, changeset} ->
    #     conn
    #     |> put_status(:unprocessable_entity)
    #     |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    # end

    params = %{"attributes" => attributes, "admin" => Guardian.Plug.current_resource(conn)}

    case create_team(params) do
      {:ok, team} ->
        Logger.info "#{inspect team}"
        conn
        |> put_status(:created)
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

  defp generate_unique_id(id) do
    Hashids.encode(@hashconfig, id)
  end

  # defp create_team(params) do
  #   Repo.transaction fn ->
  #     case insert_team(params) do
  #       {:ok, team} ->
  #         case add_unique_id_to_team(team) do
  #           {:ok, updated_team} ->
  #             updated_team
  #           {:error, changeset} ->
  #             changeset
  #         end
  #       {:error, changeset} ->
  #         Repo.rollback changeset
  #     end
  #   end
  # end

  defp create_team(params) do
    Repo.transaction fn ->
      with {:ok, team} <- insert_team(params),
           {:ok, updated_team} <- add_unique_id_to_team(team) do
             updated_team
      else
        {:error, changeset} ->
          Repo.rollback changeset
      end
    end
  end

  defp insert_team(params) do
    %Team{}
    |> Team.changeset(%{name: params["attributes"]["name"], isAnonymous: true, avatar: "default.png"})
    |> Ecto.Changeset.put_assoc(:admin, params["admin"])
    |> Repo.insert
  end

  defp add_unique_id_to_team(team) do
    team_unique_id = generate_unique_id(team.id)

    team
    |> Team.changeset(%{uuid: team_unique_id})
    |> Repo.update
  end
end
