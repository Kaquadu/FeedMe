defmodule FeedWeb.ProductController do
  use FeedWeb, :controller

  alias Feed.Diets

  def index(%{assigns: %{user: user}} = conn, %{"product" => product_name}) do
    products = Diets.get_user_products(user.id, product_name)
    render(conn, "index.html", products: products)
  end

  def index(%{assigns: %{user: user}} = conn, _params) do
    products = Diets.get_user_products(user.id)
    render(conn, "index.html", products: products)
  end

  def delete(conn, %{"id" => id}) do
    id
    |> Diets.get_product_by_id()
    |> Diets.delete_product()
    |> case do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Successfully deleted #{product.name}")
        |> redirect(to: Routes.product_path(conn, :index))
      {:error, product} ->
        conn
        |> put_flash(:error, "Cannot delete #{product.name}")
        |> redirect(to: Routes.product_path(conn, :index))
    end
  end
end
