defmodule MirrorWeb.MemberDelegateControllerTest do
  use MirrorWeb.ConnCase

  alias Mirror.Teams
  alias Mirror.Teams.MemberDelegate

  @create_attrs %{access_code: "some access_code", email: "some email", is_accessed: true}
  @update_attrs %{access_code: "some updated access_code", email: "some updated email", is_accessed: false}
  @invalid_attrs %{access_code: nil, email: nil, is_accessed: nil}

  def fixture(:member_delegate) do
    {:ok, member_delegate} = Teams.create_member_delegate(@create_attrs)
    member_delegate
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all member_delegates", %{conn: conn} do
      conn = get conn, member_delegate_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create member_delegate" do
    test "renders member_delegate when data is valid", %{conn: conn} do
      conn = post conn, member_delegate_path(conn, :create), member_delegate: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, member_delegate_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "access_code" => "some access_code",
        "email" => "some email",
        "is_accessed" => true}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, member_delegate_path(conn, :create), member_delegate: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update member_delegate" do
    setup [:create_member_delegate]

    test "renders member_delegate when data is valid", %{conn: conn, member_delegate: %MemberDelegate{id: id} = member_delegate} do
      conn = put conn, member_delegate_path(conn, :update, member_delegate), member_delegate: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, member_delegate_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "access_code" => "some updated access_code",
        "email" => "some updated email",
        "is_accessed" => false}
    end

    test "renders errors when data is invalid", %{conn: conn, member_delegate: member_delegate} do
      conn = put conn, member_delegate_path(conn, :update, member_delegate), member_delegate: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete member_delegate" do
    setup [:create_member_delegate]

    test "deletes chosen member_delegate", %{conn: conn, member_delegate: member_delegate} do
      conn = delete conn, member_delegate_path(conn, :delete, member_delegate)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, member_delegate_path(conn, :show, member_delegate)
      end
    end
  end

  defp create_member_delegate(_) do
    member_delegate = fixture(:member_delegate)
    {:ok, member_delegate: member_delegate}
  end
end
