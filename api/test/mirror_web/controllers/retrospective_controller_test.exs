defmodule MirrorWeb.RetrospectiveControllerTest do
  use MirrorWeb.ConnCase

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.Retrospective

  @create_attrs %{cancelled: true, is_anonymous: true, name: "some name", state: 42}
  @update_attrs %{cancelled: false, is_anonymous: false, name: "some updated name", state: 43}
  @invalid_attrs %{cancelled: nil, is_anonymous: nil, name: nil, state: nil}

  def fixture(:retrospective) do
    {:ok, retrospective} = Retrospectives.create_retrospective(@create_attrs)
    retrospective
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all retrospectives", %{conn: conn} do
      conn = get conn, retrospective_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create retrospective" do
    test "renders retrospective when data is valid", %{conn: conn} do
      conn = post conn, retrospective_path(conn, :create), retrospective: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, retrospective_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "cancelled" => true,
        "is_anonymous" => true,
        "name" => "some name",
        "state" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, retrospective_path(conn, :create), retrospective: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update retrospective" do
    setup [:create_retrospective]

    test "renders retrospective when data is valid", %{conn: conn, retrospective: %Retrospective{id: id} = retrospective} do
      conn = put conn, retrospective_path(conn, :update, retrospective), retrospective: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, retrospective_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "cancelled" => false,
        "is_anonymous" => false,
        "name" => "some updated name",
        "state" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, retrospective: retrospective} do
      conn = put conn, retrospective_path(conn, :update, retrospective), retrospective: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete retrospective" do
    setup [:create_retrospective]

    test "deletes chosen retrospective", %{conn: conn, retrospective: retrospective} do
      conn = delete conn, retrospective_path(conn, :delete, retrospective)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, retrospective_path(conn, :show, retrospective)
      end
    end
  end

  defp create_retrospective(_) do
    retrospective = fixture(:retrospective)
    {:ok, retrospective: retrospective}
  end
end
