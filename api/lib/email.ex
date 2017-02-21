defmodule Mirror.Email do
  use Bamboo.Phoenix, view: Mirror.EmailView

  def welcome_text_email(email_address, access_code) do
    new_email
    |> to(email_address)
    |> from("noreply@mail.usemirror.io")
    |> subject("Welcome!")
    |> text_body("Welcome to Mirror! Your access code is #{access_code}")
  end
end