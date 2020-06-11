defmodule FeedWeb.DietController do
  use FeedWeb, :controller

  alias Feed.Diets
  alias Feed.Diets.Diet

  plug :append_diet
  plug :authorize_user

  def index(%{assigns: %{user: user}} = conn, _params) do
    diets = Diets.get_user_diets(user.id)
    render(conn, "index.html", diets: diets)
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

  def delete(conn, %{"id" => diet}) do
    case Diets.delete_diet(diet) do
      {1, nil} ->
        conn
        |> put_flash(:info, "Diet deleted")
        |> redirect(to: Routes.page_path(conn, :index))
      _other ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def request_meal(conn, %{"id" => diet_id}) do
    diet_data = Diets.get_diet_data(diet_id)
    render(conn, "request_meal.html.eex", diet_data)
  end

  defp append_diet(conn, _) do
    conn
  end

  defp authorize_user(conn, _) do
    conn
  end
end
