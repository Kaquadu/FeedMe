defmodule FeedWeb.UserHelper do
  import Plug.Conn

  def fetch_user(conn) do
    case get_session(conn, :user_session) do
      nil -> nil
      session ->
        Feed.Auth.get_user_by(%{"id" => session.user_id})
    end
  end
end
