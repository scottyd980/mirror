defmodule MirrorWeb.UserController do
  use MirrorWeb, :controller

  alias Mirror.Accounts
  alias Mirror.Accounts.User

  alias Mirror.Email
  alias Mirror.Mailer

  require Logger

  action_fallback MirrorWeb.FallbackController

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json-api", data: user |> User.preload_relationships)
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

  # TODO: Future - Not needed for release
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

    Logger.warn "#{inspect conn}"

    conn
    |> render("show.json-api", data: user |> User.preload_relationships)
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

  def forgot_username(conn, %{"email" => email}) do
    with %User{} = user <- Accounts.get_user_by_email(email) do
      Email.forgot_username_email(user.email, user.username)
      |> Mailer.deliver_later

      conn
      |> put_status(200)
      |> json(%{})
    else
      _ ->
        conn
        |> put_status(200)
        |> json(%{})
    end
  end

  def forgot_password(conn, %{"email" => email}) do
    with %User{} = user                 <- Accounts.get_user_by_email(email),
         {:ok, %User{} = updated_user}  <- Accounts.begin_user_password_recovery(user) do

      Email.forgot_password_email(updated_user.email, updated_user.username, updated_user.reset_password_token)
      |> Mailer.deliver_later

      conn
      |> put_status(200)
      |> json(%{})
    else
      _ ->
        conn
        |> put_status(200)
        |> json(%{})
    end
  end

  def reset_password(conn, %{"reset_token" => reset_token, "new_password" => new_password, "new_password_confirmation" => new_password_confirmation}) do
    attrs = %{
      password: new_password,
      password_confirmation: new_password_confirmation
    }

    with %User{} = user                 <- Accounts.get_user_by_reset_token(reset_token),
         {:ok, %User{} = updated_user}  <- Accounts.reset_user_password(user, attrs) do

      conn
      |> put_status(200)
      |> json(%{})
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
      nil ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: %{})
      _ ->
        conn
        |> put_status(500)
        |> json(%{})
    end
  end
end
