defmodule Meet.BaseEmail do
  import Bamboo.Email
  import Bamboo.Phoenix
  
  def base_email() do
    new_email()
    |> from("noreply@meetme.net")
    |> put_html_layout({MeetWeb.LayoutView, "email.html"})
    |> put_text_layout({MeetWeb.LayoutView, "email.text"})
  end
end
