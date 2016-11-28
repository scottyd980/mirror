defmodule Mirror.RetrospectiveController do
  use Mirror.Web, :controller

  alias Mirror.Team
  alias Mirror.Retrospective

  require Logger

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def index(conn, _params) do
    retrospectives = Repo.all(Retrospective)
    |> Repo.preload([:moderator, :team, :type, :participants])
    render(conn, "index.json", retrospectives: retrospectives)
  end

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "retrospectives"}}) do

    Logger.warn "test"
    # team_members = [Guardian.Plug.current_resource(conn)]
    # team_admins = [Guardian.Plug.current_resource(conn)]
    # team_member_delegates = attributes["member-delegates"]
    #
    # params = %{"attributes" => attributes, "admins" => team_admins, "members" => team_members, "delegates" => team_member_delegates}
    #
    # case create_team(params) do
    #   {:ok, team} ->
    #     conn
    #     |> put_status(:created)
    #     |> render("show.json", team: team)
    #   {:error, changeset} ->
    #     conn
    #     |> put_status(:unprocessable_entity)
    #     |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    # end

  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    team = Repo.get!(Team, id)
    |> Repo.preload([:admins, :members])

    case Enum.member?(team.members, current_user) do
      true ->
        render(conn, "show.json", team: team)
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json")
    end
  end

  # def update(conn, %{"id" => id, "team" => team_params}) do
  #   team = Repo.get!(Team, id)
  #   |> Repo.preload([:admins, :members])
  #   changeset = Team.changeset(team, team_params)
  #
  #   case Repo.update(changeset) do
  #     {:ok, team} ->
  #       render(conn, "show.json", team: team)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   team = Repo.get!(Team, id)
  #
  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(team)
  #
  #   send_resp(conn, :no_content, "")
  # end

  defp add_team_members(team, users) do
    cond do
      length(users) > 0 ->
        Enum.map users, fn user ->
          # %UserTeam{}
          # |> UserTeam.changeset(%{user_id: user.id, team_id: team.id})
          # |> Repo.insert
        end
      true ->
        [{:ok, nil}]
    end
  end
end
