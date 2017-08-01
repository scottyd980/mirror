defmodule Mirror.TeamController do
  use Mirror.Web, :controller

  alias Mirror.{Team, Organization, UserTeam, TeamAdmin, MemberDelegate, UserHelper, HashHelper, Retrospective, Mailer, Email, Billing}
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

    team = Repo.get_by!(Team, uuid: id)
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

    team = Repo.get_by!(Team, uuid: id)

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
  def update(conn, %{"id" => id}) do
    body_params = conn.body_params
    
    team = Repo.get_by!(Team, uuid: id)
    |> Team.preload_relationships()

    current_org = team.organization

    organization_id = body_params["data"]["relationships"]["organization"]["data"]["id"];

    # TODO: Need to make sure this is an org admin if the org is changing
    changeset_data = case is_nil(organization_id) do
      true ->
        %{organization_id: nil}
      _ ->
        organization = Repo.get_by!(Organization, uuid: organization_id)
        %{organization_id: organization.id}
    end

    changeset_data = Map.put(changeset_data, :isAnonymous, body_params["data"]["attributes"]["is-anonymous"]);

    changeset = Team.changeset(team, changeset_data)

    # TODO: Need to make sure this is a team admin making changes if it's not an org change (org admin does not have to be a team admin)
    case update_team(changeset, current_org) do
      {:ok, {:ok, team}} ->
        render(conn, "show.json", team: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update_team(changeset, current_org) do
    Repo.transaction fn ->
      with {:ok, team}      <- Repo.update(changeset),
           team_with_assocs <- team |> Team.preload_relationships,
           subscriptions    <- Billing.build_subscriptions(team_with_assocs.organization),
           removed_sub      <- Billing.remove_subscription(current_org, team_with_assocs)
      do
        {:ok, team_with_assocs}
      else
        {:error, changeset} ->
          Repo.rollback changeset
          {:error, changeset}
      end
    end
  end

   # TODO: Need to finish delete
  def delete(conn, %{"id" => id}) do
    team = Repo.get_by!(Team, uuid: id)
    |> Team.preload_relationships()

    current_org = team.organization

    # TODO: Need to make sure this is an org admin
    changeset = case is_nil(current_org) || is_nil(current_org.id) do
      true ->
        Team.changeset(team, %{organization_id: nil})
      _ ->
        organization = Repo.get!(Organization, current_org.id)
        Team.changeset(team, %{organization_id: organization.id})
    end

     # TODO: Need to make sure this is a team admin making changes if it's not an org change (org admin does not have to be a team admin)
    case delete_team(team, current_org) do
      {:ok, team} ->
        render(conn, "delete.json", team: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end
  end

  defp delete_team(team, current_org) do
    Repo.transaction fn ->
      with {:ok, team}      <- Repo.delete(team),
           team_with_assocs <- team |> Team.preload_relationships,
           removed_sub      <- Billing.remove_subscription(current_org, team_with_assocs, true)
      do
        {:ok, team}
      else
        {:error, changeset} ->
          Repo.rollback changeset
          {:error, changeset}
      end
    end
  end

  defp create_team(params) do
    Repo.transaction fn ->
      with {:ok, team} <- insert_team(params),
           {:ok, updated_team} <- add_unique_id_to_team(team),
           [{:ok, team_admins}] <- add_team_admins(team, params["admins"]),
           team_member_delegates <- add_team_member_delegates(team, params["delegates"]),
           {:ok} <- send_delegate_emails(team_member_delegates, team),
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
    team_unique_id = HashHelper.generate_unique_id(team.id, "team")

    team
    |> Team.changeset(%{uuid: team_unique_id})
    |> Repo.update
  end

  defp generate_unique_id(id) do
    Hashids.encode(@hashconfig, id)
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

  defp send_delegate_emails(delegates, team) do
    Enum.each(delegates, fn delegate ->
      Email.join_html_email(delegate.email, delegate.access_code, team.name) 
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
