defmodule MeetWeb.Auth.UserController do
  use MeetWeb, :controller

  alias Meet.Auth
  alias Meet.Auth.User

  def new(conn, _) do
    cs = User.changeset(%User{})
    render(conn, "new.html", changeset: cs)
  end

  def create(conn, %{"user" => user_attrs}) do
    case Auth.create_user(user_attrs) do
      {:ok, _user} -> succesful_create_redirect(conn)
      {:error, changeset} -> unsuccesful_create_redirect(conn, changeset)
    end
  end

  defp succesful_create_redirect(conn) do
    conn
    |> put_flash(:info, "Created an user. Please confirm your email.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp unsuccesful_create_redirect(conn, changeset) do
    conn
    |> put_flash(:error, "Can't create user. Check errors below.")
    |> redirect(to: Routes.user_path(conn, :new, changeset: changeset))
  end
end
