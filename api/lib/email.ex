defmodule Mirror.Email do
  use Bamboo.Phoenix, view: Mirror.EmailView

  def join_html_email(email_address, access_code, team_name) do
    new_email
    |> to(email_address)
    |> from("noreply@***MAIL_DOMAIN***")
    |> subject("Welcome To Mirror | Successful, Distributed Retrospectives")
    |> put_html_layout({Mirror.LayoutView, "join.html"})
    |> render("join.html", access_code: access_code, team: team_name)
  end
end