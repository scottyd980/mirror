defmodule Mirror.TeamController do
  use Mirror.Web, :controller

  alias Mirror.{Team, UserTeam, TeamAdmin, MemberDelegate, UserHelper, Retrospective, Mailer, Email}
  alias Ecto.{Multi}

  import Logger

  @hashconfig Hashids.new([
    salt: "?d[]?a5$~<).hU%L}0k-krUz>^[xJ@Y(yAna%`-k4Hs{^=5T6@/k]PFqkJ;FlbV+",  # using a custom salt helps producing unique cipher text
    min_len: 6,   # minimum length of the cipher text (1 by default)
  ])

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def index(conn, _params) do
    teams = Repo.all(Team)
    |> Team.preload_relationships()
    render(conn, "index.json", teams: teams)
  end

  def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "teams"}}) do

    team_members = [Guardian.Plug.current_resource(conn)]
    team_admins = [Guardian.Plug.current_resource(conn)]
    team_member_delegates = attributes["member-delegates"]

    params = %{"attributes" => attributes, "admins" => team_admins, "members" => team_members, "delegates" => team_member_delegates}

    case create_team(params) do
      {:ok, team} ->
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

  def get_next_sprint(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    team = Repo.get!(Team, id)

    case UserHelper.user_is_team_member?(current_user, team) do
      true ->
        next_sprint = Team.get_next_retrospective(team)
        render(conn, "next_sprint.json", %{next_sprint: next_sprint, team: team})
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json")
    end
  end

  # TODO: Need to finish update
  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Repo.get!(Team, id)
    |> Team.preload_relationships()
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

  defp create_team(params) do
    Repo.transaction fn ->
      with {:ok, team} <- insert_team(params),
           {:ok, updated_team} <- add_unique_id_to_team(team),
           [{:ok, team_admins}] <- add_team_admins(team, params["admins"]),
           team_member_delegates <- add_team_member_delegates(team, params["delegates"]),
           {:ok} <- send_delegate_emails(team_member_delegates),
           [{:ok, team_members}] <- add_team_members(team, params["members"]) do
             updated_team
             |> Team.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
      end
    end
  end

  defp insert_team(params) do
    %Team{}
    |> Team.changeset(%{name: params["attributes"]["name"], isAnonymous: true, avatar: "default.png"})
    |> Repo.insert
  end

  defp add_unique_id_to_team(team) do
    team_unique_id = generate_unique_id(team.id)

    team
    |> Team.changeset(%{uuid: team_unique_id})
    |> Repo.update
  end

  defp add_team_members(team, users) do
    cond do
      length(users) > 0 ->
        Enum.map users, fn user ->
          %UserTeam{}
          |> UserTeam.changeset(%{user_id: user.id, team_id: team.id})
          |> Repo.insert
        end
      true ->
        [{:ok, nil}]
    end
  end

  defp add_team_member_delegates(team, delegates) do
    cond do
      length(delegates) > 0 ->
        Enum.map delegates, fn delegate ->
          %MemberDelegate{}
          |> MemberDelegate.changeset(%{email: delegate, team_id: team.id})
          |> Repo.insert!
        end
      true ->
        []
    end
  end

  defp send_delegate_emails(delegates) do
    Enum.each(delegates, fn delegate ->
      Email.welcome_text_email(delegate.email, delegate.access_code) 
      |> Mailer.deliver_later
    end)

    {:ok}
  end

  defp add_team_admins(team, admins) do
    Enum.map admins, fn admin ->
      %TeamAdmin{}
      |> TeamAdmin.changeset(%{user_id: admin.id, team_id: team.id})
      |> Repo.insert
    end
  end
end
