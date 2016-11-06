defmodule Mirror.UserController do
  use Mirror.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  import Logger

  alias Mirror.User

  def current(conn, _) do
    user = conn
    |> Guardian.Plug.current_resource
    |> Repo.preload([:teams])

    conn
    |> render(Mirror.UserView, "show.json", user: user)
  end

  def show(conn, %{"id" => id}) do
    # current_user = Guardian.Plug.current_resource(conn)

    # We really need to make sure here that the current team member is in
    # the same organization / team as the user they're looking for

    user = Repo.get!(User, id)
    |> Repo.preload([:teams])

    conn
    |> render(Mirror.UserView, "show.json", user: user)

    # case Enum.member?(team.members, current_user) do
    #   true ->
    #     render(conn, "show.json", team: team)
    #   _ ->
    #     conn
    #     |> put_status(404)
    #     |> render(Mirror.ErrorView, "404.json")
    # end
  end
end
