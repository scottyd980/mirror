defmodule MirrorWeb.TeamControllerTest do
  use MirrorWeb.ConnCase

  alias Mirror.Teams
  alias Mirror.Teams.Team

  @create_attrs %{avatar: "some avatar", is_anonymous: true, name: "some name", uuid: "some uuid"}
  @update_attrs %{avatar: "some updated avatar", is_anonymous: false, name: "some updated name", uuid: "some updated uuid"}
  @invalid_attrs %{avatar: nil, is_anonymous: nil, name: nil, uuid: nil}

  def fixture(:team) do
    {:ok, team} = Teams.create_team(@create_attrs)
    team
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all teams", %{conn: conn} do
      conn = get conn, team_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create team" do
    test "renders team when data is valid", %{conn: conn} do
      conn = post conn, team_path(conn, :create), team: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, team_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "avatar" => "some avatar",
        "is_anonymous" => true,
        "name" => "some name",
        "uuid" => "some uuid"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, team_path(conn, :create), team: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update team" do
    setup [:create_team]

    test "renders team when data is valid", %{conn: conn, team: %Team{id: id} = team} do
      conn = put conn, team_path(conn, :update, team), team: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, team_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "avatar" => "some updated avatar",
        "is_anonymous" => false,
        "name" => "some updated name",
        "uuid" => "some updated uuid"}
    end

    test "renders errors when data is invalid", %{conn: conn, team: team} do
      conn = put conn, team_path(conn, :update, team), team: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete team" do
    setup [:create_team]

    test "deletes chosen team", %{conn: conn, team: team} do
      conn = delete conn, team_path(conn, :delete, team)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, team_path(conn, :show, team)
      end
    end
  end

  defp create_team(_) do
    team = fixture(:team)
    {:ok, team: team}
  end
end
