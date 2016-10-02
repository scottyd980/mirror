defmodule Mirror.UserController do
  use Mirror.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def current(conn, _) do
    user = conn
    |> Guardian.Plug.current_resource

    conn
    |> render(Mirror.UserView, "show.json", user: user)
  end
end
