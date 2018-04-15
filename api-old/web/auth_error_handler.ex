defmodule Mirror.AuthErrorHandler do
 use Mirror.Web, :controller

 def unauthenticated(conn, params) do
  conn
   |> put_status(401)
   |> render(Mirror.ErrorView, "401.json")
 end

 def unauthorized(conn, params) do
  conn
   |> put_status(403)
   |> render(Mirror.ErrorView, "403.json")
 end
end
