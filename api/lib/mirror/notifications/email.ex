defmodule Mirror.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: MirrorWeb.EmailView

  def invitation_email(email_address, access_code, team_name) do
    new_email()
    |> to(email_address)
    |> from("noreply@***MAIL_DOMAIN***")
    |> subject("Welcome To Mirror | Successful, Distributed Retrospectives")
    |> put_html_layout({MirrorWeb.LayoutView, "invite.html"})
    |> render("invite.html", access_code: access_code, team: team_name)
  end
end