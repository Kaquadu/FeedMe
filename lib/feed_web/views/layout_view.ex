defmodule FeedWeb.LayoutView do
  use FeedWeb, :view

  import Plug.Conn

  def has_session?(conn) do
    case get_session(conn, :user_session) do
      nil -> false
      _ -> true
    end
  end

  def extract_session(conn), do: get_session(conn, :user_session)
end
