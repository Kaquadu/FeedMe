defmodule FeedWeb.SessionExpirationPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> get_session(:user_session)
    |> case do
      nil -> conn
      session -> check_session(conn, session)
    end
  end

  def check_session(conn, session) do
    if NaiveDateTime.compare(session.valid_until, DateTime.utc_now()) == :lt do
      delete_session(conn, :user_session)
    else
      conn
    end
  end
end
