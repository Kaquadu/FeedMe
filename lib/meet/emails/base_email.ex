defmodule Feed.BaseEmail do
  import Bamboo.Email
  import Bamboo.Phoenix

  def base_email() do
    new_email()
    |> from("noreply@feedme.net")
    |> put_html_layout({FeedWeb.LayoutView, "email.html"})
    |> put_text_layout({FeedWeb.LayoutView, "email.text"})
  end
end
