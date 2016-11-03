defmodule Mirror.SessionControllerTest do
  use Mirror.ConnCase

  alias Mirror.User

  @valid_attrs %{
    grant_type: "password",
    username: "test",
    password: "password"
  }

  @invalid_password_attrs %{
    grant_type: "password",
    username: "test",
    password: "wrong_password"
  }

  @no_username_attrs %{
    grant_type: "password",
    username: "",
    password: "password"
  }

  @no_attrs %{}

  setup %{conn: conn} do
    user = Repo.insert! %User{
      "email": "test@test.com",
      "username": "test",
      "password_hash": "$2b$12$xC574rj0MrM8rhahZwUGo.c4SBOhbTAmVwTWUfia6TVrJHBCWG39G"
    }

    conn = conn
    |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, %{conn: conn, user: user}}
  end

  test "logs in the user when valid credentials are provided", %{conn: conn} do
    conn = post conn, login_path(conn, :create), @valid_attrs
    assert json_response(conn, 201)
  end

  test "fails to log in (unauthorized) the user when invalid credentials are provided", %{conn: conn} do
    conn = post conn, login_path(conn, :create), @invalid_password_attrs
    assert json_response(conn, 401)
  end

  test "fails to log in (unauthorized) the user when no username is provided", %{conn: conn} do
    conn = post conn, login_path(conn, :create), @no_username_attrs
    assert json_response(conn, 401)
  end

  test "fails hard (unauthorized) when the user provides no attributes", %{conn: conn} do
    conn = post conn, login_path(conn, :create), @no_attrs
    assert json_response(conn, 401)
  end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   assert_error_sent 400, fn ->
  #     conn = post conn, registration_path(conn, :create),  %{data: %{type: "users",
  #       attributes: @invalid_attrs
  #     }}
  #   end
  # end

end
