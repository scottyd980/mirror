defmodule MirrorWeb.UserController do
  use MirrorWeb, :controller

  alias Mirror.Accounts
  alias Mirror.Accounts.User

  action_fallback MirrorWeb.FallbackController

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json-api", data: user)
  end

  def create(conn, %{"data" => data}) do
    user_params = JaSerializer.Params.to_attributes(data)
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) 
    do
      conn
      |> put_status(:created)
      |> render("show.json-api", data: user |> User.preload_relationships)
    else
      {:error, changeset} -> 
        conn
        |> put_status(:unprocessable_entity)
        |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
  
  # TODO: Future
  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Accounts.get_user!(id)

  #   with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
  #     render(conn, "show.json", user: user)
  #   end
  # end

  def current(conn, _) do
    user = conn
    |> Mirror.Guardian.Plug.current_resource
    |> User.preload_relationships

    conn
    |> render("show.json-api", data: user)
  end

  def login(conn, %{"grant_type" => "password", "username" => username, "password" => password}) do
    with {:ok, jwt, _} <- User.login(username, password)
    do
      conn
      |> put_status(201)
      |> json(%{access_token: jwt}) # Return token to the client
    else
      {:error, _} ->
        conn
        |> put_status(401)
        |> render(MirrorWeb.ErrorView, "401.json") # 401
    end
  end
end
