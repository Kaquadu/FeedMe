defmodule FeedWeb.CheckSessionPlug do
  import Phoenix.Controller
  import Plug.Conn

  alias FeedWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> get_session(:user_session)
    |> case do
      nil ->
        conn
        |> put_flash(:error, "You need to sign in before performing that action.")
        |> redirect(to: Routes.page_path(conn, :index))
      _ -> conn
    end
  end
end
