defmodule Mirror.TeamControllerTest do
  use Mirror.ConnCase

  alias Mirror.Team
  alias Mirror.User
  alias Mirror.UserTeam

  import Logger

  @valid_attrs %{avatar: "avatar", isAnonymous: true, name: "some content"}
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

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, team_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource if user is a team member", %{conn: conn, user: user} do
    team = Repo.insert! %Team{}

    add_as_team_member(user, team)

    conn = get conn, team_path(conn, :show, team)

    assert json_response(conn, 200)["data"] == %{
      "id" => team.id,
      "attributes" => %{
        "avatar" => team.avatar,
        "is-anonymous" => team.isAnonymous,
        "name" => team.name
      },
      "relationships" => %{
        "admins" => %{
          "data" => [],
          "links" => %{
            "self" => "/api/users/"
          }
        },
        "members" => %{
          "data" => [
            %{"id" => user.id, "type" => "user"}
          ],
          "links" => %{
            "self" => "/api/users/"
          }
        }
      },
      "type" => "team"
    }
  end

  test "does not show chosen resource if user is not a team member", %{conn: conn, user: user} do
    team = Repo.insert! %Team{}
    conn = get conn, team_path(conn, :show, team)

    assert conn.status == 404
  end
  #
  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, team_path(conn, :show, -1)
  #   end
  # end
  #
  # test "creates and renders resource when data is valid", %{conn: conn} do
  #   conn = post conn, team_path(conn, :create), team: @valid_attrs
  #   assert json_response(conn, 201)["data"]["id"]
  #   assert Repo.get_by(Team, @valid_attrs)
  # end
  #
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, team_path(conn, :create), team: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end
  #
  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   team = Repo.insert! %Team{}
  #   conn = put conn, team_path(conn, :update, team), team: @valid_attrs
  #   assert json_response(conn, 200)["data"]["id"]
  #   assert Repo.get_by(Team, @valid_attrs)
  # end
  #
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   team = Repo.insert! %Team{}
  #   conn = put conn, team_path(conn, :update, team), team: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end
  #
  # test "deletes chosen resource", %{conn: conn} do
  #   team = Repo.insert! %Team{}
  #   conn = delete conn, team_path(conn, :delete, team)
  #   assert response(conn, 204)
  #   refute Repo.get(Team, team.id)
  # end
end
