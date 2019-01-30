defmodule Mirror.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: MirrorWeb.EmailView

  def invitation_email(email_address, access_code, team_name) do
    new_email()
    |> to(email_address)
    |> from("Mirror <noreply@mail.usemirror.io>")
    |> subject("Someone invited you to join a team!")
    |> put_html_layout({MirrorWeb.LayoutView, "invite2.html"})
    |> render("invite.html", access_code: access_code, team: team_name)
  end

  def forgot_username_email(email_address, username) do
    new_email()
    |> to(email_address)
    |> from("Mirror <noreply@mail.usemirror.io>")
    |> subject("Your Forgotten Username Request")
    |> put_html_layout({MirrorWeb.LayoutView, "username.html"})
    |> render("username.html", username: username)
  end

  def forgot_password_email(email_address, username, uuid) do
    new_email()
    |> to(email_address)
    |> from("Mirror <noreply@mail.usemirror.io>")
    |> subject("Your Password Reset Request")
    |> put_html_layout({MirrorWeb.LayoutView, "password.html"})
    |> render("password.html", username: username, uuid: uuid)
  end
end
