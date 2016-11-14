defmodule Mirror.TeamAdminControllerTest do
  use Mirror.ConnCase

  alias Mirror.Team
  alias Mirror.User
  alias Mirror.UserTeam
  alias Mirror.TeamAdmin
  alias Mirror.MemberDelegate

  import Logger

  @valid_attrs %{avatar: "avatar", isAnonymous: true, name: "some content", "member-delegates": []}
  @valid_member_delegate_attrs %{avatar: "avatar", isAnonymous: true, name: "some content", "member-delegates": ["test@test.com"]}
  @invalid_attrs %{}

  defp add_as_team_member(user, team) do
    Repo.insert! %UserTeam{team_id: team.id, user_id: user.id}
  end

  defp add_as_team_admin(user, team) do
    Repo.insert! %TeamAdmin{team_id: team.id, user_id: user.id}
  end

  setup %{conn: conn} do
    user = Repo.insert! %User{}
    { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)
    conn = conn
    |> put_req_header("content-type", "application/vnd.api+json")
    |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, %{conn: conn, user: user}}
  end

  test "does not create admin and returns 401 when data is valid and current user is not an admin member", %{conn: conn, user: user} do
    team = Repo.insert! %Team{}
    add_as_team_member(user, team)

    new_user = Repo.insert! %User{}

    conn = post conn, team_admin_path(conn, :create), %{"admin_id": new_user.id, "team_id": team.id}
    assert json_response(conn, 401) == %{"errors" => []}
  end

  test "does not create admin and returns 403 when data is valid but new admin user is not a member of the team", %{conn: conn, user: user} do
    team = Repo.insert! %Team{}
    add_as_team_member(user, team)
    add_as_team_admin(user, team)

    new_user = Repo.insert! %User{}

    conn = post conn, team_admin_path(conn, :create), %{"admin_id": new_user.id, "team_id": team.id}
    assert json_response(conn, 403) == %{"errors" => []}
  end

  test "creates a new admin and returns 201 when data is valid and current user is an admin of the team", %{conn: conn, user: user} do
    team = Repo.insert! %Team{}
    add_as_team_member(user, team)
    add_as_team_admin(user, team)

    new_user = Repo.insert! %User{}
    add_as_team_member(new_user, team)

    conn = post conn, team_admin_path(conn, :create), %{"admin_id": new_user.id, "team_id": team.id}
    assert json_response(conn, 201)["data"] == %{
    	"type" => "team_admin",
      "attributes" => %{
      	"team_id" => team.id,
        "admin_id" => new_user.id
    	}
    }
  end

  test "deletes an admin and returns a 200 when data is a valid team member", %{conn: conn, user: user} do
    team = Repo.insert! %Team{}
    add_as_team_member(user, team)
    add_as_team_admin(user, team)

    # Add an additional user as an admin
    new_user = Repo.insert! %User{}
    add_as_team_member(new_user, team)
    add_as_team_admin(new_user, team)

    conn = delete conn, team_admin_path(conn, :delete), %{"admin_id": user.id, "team_id": team.id}
    assert json_response(conn, 200) == %{"meta" => %{}}
  end

  test "does not delete an admin and returns a 401 when data is a valid but current user is not a team admin", %{conn: conn, user: user} do
    team = Repo.insert! %Team{}
    add_as_team_member(user, team)

    # Add an additional user as an admin
    new_user = Repo.insert! %User{}
    add_as_team_member(new_user, team)
    add_as_team_admin(new_user, team)

    conn = delete conn, team_admin_path(conn, :delete), %{"admin_id": user.id, "team_id": team.id}
    assert json_response(conn, 401) == %{"errors" => []}
  end

  # test "deletes a user who is an admin and returns a 200 when user is a valid team member and is not the only admin", %{conn: conn, user: user} do
  #   # Create a team and add the current user as a team member and team admin
  #   team = Repo.insert! %Team{}
  #   add_as_team_member(user, team)
  #   add_as_team_admin(user, team)
  #
  #   # Add an additional admin to the team
  #   new_user = Repo.insert! %User{}
  #   add_as_team_member(new_user, team)
  #   add_as_team_admin(new_user, team)
  #
  #   conn = delete conn, user_team_path(conn, :delete), %{"user_id": user.id, "team_id": team.id}
  #   assert json_response(conn, 200) == %{"meta" => %{}}
  # end
  #
  # test "does not delete a user who is the only remaining admin and returns a 403", %{conn: conn, user: user} do
  #   # Create a team and add the current user as a team member and team admin
  #   team = Repo.insert! %Team{}
  #   add_as_team_member(user, team)
  #   add_as_team_admin(user, team)
  #
  #   conn = delete conn, user_team_path(conn, :delete), %{"user_id": user.id, "team_id": team.id}
  #   assert json_response(conn, 403) == %{"errors" => []}
  # end
  #
  # test "user, who is not a member of the team, tries to remove a member of the team and returns a 401", %{conn: conn, user: user} do
  #   # Create a team but don't add the current logged in user to it
  #   team = Repo.insert! %Team{}
  #
  #   # Add an additional user to be added the team
  #   new_user = Repo.insert! %User{}
  #   add_as_team_member(new_user, team)
  #
  #   conn = delete conn, user_team_path(conn, :delete), %{"user_id": new_user.id, "team_id": team.id}
  #   assert json_response(conn, 401) == %{"errors" => []}
  # end

end
