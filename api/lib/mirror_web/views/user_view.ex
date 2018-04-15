defmodule MirrorWeb.UserView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView
  # alias MirrorWeb.UserView

  attributes [:username, :email]

  # def render("index.json", %{users: users}) do
  #   %{data: render_many(users, UserView, "user.json")}
  # end

  # def render("show.json", %{user: user}) do
  #   %{data: render_one(user, UserView, "user.json")}
  # end

  # def render("user.json", %{user: user}) do
  #   %{id: user.id,
  #     username: user.username,
  #     email: user.email,
  #     password_hash: user.password_hash,
  #     password: user.password,
  #     password_confirmation: user.password_confirmation}
  # end
end
