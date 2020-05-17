defmodule FeedWeb.DietController do
  use FeedWeb, :controller

  alias Feed.Diets
  alias Feed.Diets.Diet

  plug :append_diet
  plug :authorize_user

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: Diet.changeset(%Diet{}))
  end

  def create(conn, %{"diet" => diet}) do
    case Diets.create_diet(diet) do
      {:ok, _diet} ->
        conn
        |> put_flash(:info, "Diet created")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> render("new.html", changeset: changeset)
    end
  end

  defp append_diet(conn, _) do
    conn
  end

  defp authorize_user(conn, _) do
    conn
  end
end
