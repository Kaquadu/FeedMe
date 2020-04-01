defmodule MeetWeb.SessionController do
  use MeetWeb, :controller

  alias Meet.Sessions
  alias Meet.Sessions.UserSession

  def new(conn, _params) do
    render(conn, "new.html", changeset: UserSession.changeset(%UserSession{}))
  end

  def create(conn, %{"user_session" => credentials}) do
    case Sessions.sign_in_user(credentials) do
      {:ok, session} ->
        conn
        |> put_session(:session, session)
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, message} -> error_sign_in_redirect(conn, message)
      _ -> error_sign_in_redirect(conn, "Something went wrong.")
    end
  end

  def delete(conn, %{"id" => id}) do
    Sessions.terminate_session(id)

    conn
    |> put_session(:session, nil)
    |> put_flash(:info, "Signed out.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp error_sign_in_redirect(conn, message) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
