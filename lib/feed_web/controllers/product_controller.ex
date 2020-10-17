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

  def edit(conn, %{"id" => id}) do
    pr = Diets.get_product_by_id(id)
    cs = Feed.Diets.Product.changeset(pr)
    render(conn, "edit.html", changeset: cs, product: pr)
  end

  def update(conn, %{"id" => id, "product" => params}) do
    product = Diets.get_product_by_id(id)

    product
    |> Diets.update_product(params)
    |> case do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Successfully updated #{product.name}")
        |> redirect(to: Routes.product_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Cannot update #{product.name}")
        |> render("edit.html", changeset: changeset, product: product)
    end
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
