defmodule Mirror.RegistrationController do
  use Mirror.Web, :controller

  alias Mirror.User

  def create(conn, %{"data" => %{"type" => "users",
    "attributes" => %{
      "username" => username,
      "email" => email,
      "password" => password,
      "password-confirmation" => password_confirmation}}}) do

    changeset = User.changeset %User{}, %{
      username: username,
      email: email,
      password_confirmation: password_confirmation,
      password: password}

    case Repo.insert changeset do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render(Mirror.UserView, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end

  end
end
