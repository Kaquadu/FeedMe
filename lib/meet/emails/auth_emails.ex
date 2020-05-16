defmodule Feed.AuthEmails do
  use Bamboo.Phoenix, view: FeedWeb.EmailsView
  import Feed.BaseEmail
  import Feed.Mailer

  def send_confirmation_email(user) do
    base_email()
    |> to(user.email)
    |> subject("Confirm your email on FeedMe")
    |> assign(:user, user)
    |> render(:email_confirmation)
    |> deliver_later()
  end
end
