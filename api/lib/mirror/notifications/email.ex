defmodule Mirror.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: MirrorWeb.EmailView

  def invitation_email(email_address, access_code, team_name) do
    new_email()
    |> to(email_address)
    |> from("Mirror <noreply@mail.usemirror.io>")
    |> subject("Someone invited you to join a team!")
    |> put_html_layout({MirrorWeb.LayoutView, "invite2.html"})
    |> render("invite2.html", access_code: access_code, team: team_name)
  end
end