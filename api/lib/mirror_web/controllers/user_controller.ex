defmodule MirrorWeb.UserController do
  use MirrorWeb, :controller

  alias Mirror.Accounts
  alias Mirror.Accounts.User

  import Comeonin.Bcrypt
  
  require Logger

  action_fallback MirrorWeb.FallbackController

  def create(conn, %{"data" => data}) do
    user_params = JaSerializer.Params.to_attributes(data)
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) 
    do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json-api", user: user)
    else
      {:error, changeset} -> 
        conn
        |> put_status(:unprocessable_entity)
        |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  # def create(conn, %{"data" => %{"type" => "users",
  #   "attributes" => %{
  #     "username" => username,
  #     "email" => email,
  #     "password" => password,
  #     "password-confirmation" => password_confirmation}}}) do

  #   changeset = User.changeset %User{}, %{
  #     username: username,
  #     email: email,
  #     password_confirmation: password_confirmation,
  #     password: password}

  #   case Repo.insert changeset do
  #     {:ok, user} ->
  #       user = user
  #       |> User.preload_relationships()
  #       conn
  #       |> put_status(:created)
  #       |> render(Mirror.UserView, "show.json", user: user)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  #   end

  # end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json-api", data: user)
  end

  def current(conn, _) do
    user = conn
    |> Mirror.Guardian.Plug.current_resource
    |> User.preload_relationships

    conn
    |> render("show.json-api", data: user)
  end

  def login(conn, %{"grant_type" => "password", "username" => username, "password" => password}) do

    try do
      # Attempt to retrieve exactly one user from the DB, whose
      #   email matches the one provided with the login request
      user = Accounts.find_user!(username)
      cond do
        checkpw(password, user.password_hash) ->
          # Successful login
          Logger.info "LOG IN - SUCCESS: #{username}"
          # Encode a JWT
          { :ok, jwt, _} = Mirror.Guardian.encode_and_sign(user)
          conn
          |> put_status(201)
          |> json(%{access_token: jwt}) # Return token to the client

        true ->
          # Unsuccessful login
          Logger.warn "LOG IN - FAILURE: #{username}"
          conn
          |> put_status(401)
          |> render(MirrorWeb.ErrorView, "401.json") # 401
      end
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging
        Logger.error "LOG IN - UNEXPECTED ERROR: #{username}"
        conn
        |> put_status(401)
        |> render(MirrorWeb.ErrorView, "401.json") # 401
    end
  end

  # TODO: Future
  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Accounts.get_user!(id)

  #   with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
  #     render(conn, "show.json", user: user)
  #   end
  # end
end
