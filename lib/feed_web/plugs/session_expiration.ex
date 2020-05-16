defmodule FeedWeb.SessionExpirationPlug do
  import Ecto.Query
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> get_session(:user_session)
    |> case do
      nil -> conn
      _ -> check_session(conn)
    end
  end

  def check_session(conn) do
    conn
    |> check_if_exists()
    |> check_if_expired()
  end

  defp check_if_exists(conn) do
    session = get_session(conn, :user_session)

    Feed.Sessions.UserSession
    |> where([s], s.id == ^session.id)
    |> Feed.Repo.exists?()
    |> if do
      conn
    else
      delete_session(conn, :user_session)
    end
  end

  def check_if_expired(conn) do
    session = get_session(conn, :user_session)

    if session do
      if NaiveDateTime.compare(session.valid_until, DateTime.utc_now()) == :lt do
        delete_session(conn, :user_session)
      else
        conn
      end
    else
      conn
    end
  end
end
