defmodule MirrorWeb.GameControllerTest do
  use MirrorWeb.ConnCase

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.Game

  @create_attrs %{finished_state: 42, name: "some name"}
  @update_attrs %{finished_state: 43, name: "some updated name"}
  @invalid_attrs %{finished_state: nil, name: nil}

  def fixture(:game) do
    {:ok, game} = Retrospectives.create_game(@create_attrs)
    game
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all games", %{conn: conn} do
      conn = get conn, game_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create game" do
    test "renders game when data is valid", %{conn: conn} do
      conn = post conn, game_path(conn, :create), game: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, game_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "finished_state" => 42,
        "name" => "some name"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, game_path(conn, :create), game: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update game" do
    setup [:create_game]

    test "renders game when data is valid", %{conn: conn, game: %Game{id: id} = game} do
      conn = put conn, game_path(conn, :update, game), game: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, game_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "finished_state" => 43,
        "name" => "some updated name"}
    end

    test "renders errors when data is invalid", %{conn: conn, game: game} do
      conn = put conn, game_path(conn, :update, game), game: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete game" do
    setup [:create_game]

    test "deletes chosen game", %{conn: conn, game: game} do
      conn = delete conn, game_path(conn, :delete, game)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, game_path(conn, :show, game)
      end
    end
  end

  defp create_game(_) do
    game = fixture(:game)
    {:ok, game: game}
  end
end
