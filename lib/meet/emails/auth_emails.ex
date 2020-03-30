defmodule Meet.AuthEmails do
  use Bamboo.Phoenix, view: MeetWeb.EmailsView
  import Meet.BaseEmail
  import Meet.Mailer

  def send_confirmation_email(user) do
    base_email()
    |> to(user.email)
    |> subject("Confirm your email on MeetMe")
    |> assign(:user, user)
    |> render(:email_confirmation)
    |> deliver_later()
  end
end
