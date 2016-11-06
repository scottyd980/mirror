defmodule Mirror.UserTeamControllerTest do
  use Mirror.ConnCase

  alias Mirror.Team
  alias Mirror.User
  alias Mirror.UserTeam
  alias Mirror.MemberDelegate

  import Logger

  @valid_attrs %{avatar: "avatar", isAnonymous: true, name: "some content", "member-delegates": []}
  @valid_member_delegate_attrs %{avatar: "avatar", isAnonymous: true, name: "some content", "member-delegates": ["test@test.com"]}
  @invalid_attrs %{}

  defp add_as_team_member(user, team) do
    Repo.insert! %UserTeam{team_id: team.id, user_id: user.id}
  end

  setup %{conn: conn} do
    user = Repo.insert! %User{}
    { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)
    conn = conn
    |> put_req_header("content-type", "application/vnd.api+json")
    |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, %{conn: conn, user: user}}
  end

  test "creates and returns 201 when data is valid and user is not already a team member", %{conn: conn, user: user} do
    team = Repo.insert! %Team{}
    member_delegate = Repo.insert! %MemberDelegate{email: "test@test.com", team_id: team.id, access_code: "abc123"}

    conn = post conn, user_team_path(conn, :create), %{"access-code": "abc123"}
    assert json_response(conn, 201)["data"] == %{
    	"type" => "user_team",
      "attributes" => %{
      	"team_id" => team.id,
        "user_id" => user.id
    	}
    }
  end

  test "creates and returns 200 when data is valid and user is already a team member", %{conn: conn, user: user} do
    team = Repo.insert! %Team{}
    add_as_team_member(user, team)
    member_delegate = Repo.insert! %MemberDelegate{email: "test@test.com", team_id: team.id, access_code: "abc123"}

    conn = post conn, user_team_path(conn, :create), %{"access-code": "abc123"}
    assert json_response(conn, 200)["data"] == %{
    	"type" => "user_team",
      "attributes" => %{
      	"team_id" => team.id,
        "user_id" => user.id
    	}
    }
  end

end
