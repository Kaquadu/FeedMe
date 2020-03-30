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
      {:ok, _user} -> succesful_redirect(
        conn,
        "Created an user. Please confirm your email.",
        Routes.page_path(conn, :index)
      )
      {:error, changeset} -> unsuccesful_redirect(
          conn,
          "Can't create user. Check errors below.",
          Routes.user_path(conn, :new, changeset: changeset)
        )
    end
  end

  def confirm_email(conn, %{"id" => user_id}) do
    case Auth.confirm_email(user_id) do
      {:ok, _user} -> succesful_redirect(
        conn,
        "Email confirmed. You can sign in now.",
        Routes.page_path(conn, :index)
      )
      {:already_confirmed, _} ->  unsuccesful_redirect(
        conn,
        "This email has already been confirmed.",
        Routes.page_path(conn, :index)
      )
      {:error, _changeset} -> unsuccesful_redirect(
        conn,
        "Can't confirm email. Please contact administrator.",
        Routes.page_path(conn, :index)
      )
    end
  end

  defp succesful_redirect(conn, message, path) do
    conn
    |> put_flash(:info, message)
    |> redirect(to: path)
  end

  defp unsuccesful_redirect(conn, message, path) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: path)
  end
end
