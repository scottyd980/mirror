defmodule Mirror.AuthErrorHandlerTest do
  use Mirror.ConnCase

  alias Mirror.AuthErrorHandler

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "unauthenticated method returns 401", %{conn: conn} do
    conn = AuthErrorHandler.unauthenticated(conn, %{})
    assert json_response(conn, 401)
  end

  test "unauthorized method returns 403", %{conn: conn} do
    conn = AuthErrorHandler.unauthorized(conn, %{})
    assert json_response(conn, 403)
  end

end
