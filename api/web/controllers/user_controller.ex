defmodule Mirror.UserController do
  use Mirror.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  require Logger

  def current(conn, _) do
    user = conn
    |> Guardian.Plug.current_resource
    |> Repo.preload([:teams])

    conn
    |> render(Mirror.UserView, "show.json", user: user)
  end
end
