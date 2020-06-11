defmodule FeedWeb.ProductController do
  use FeedWeb, :controller

  alias Feed.Diets

  def index(%{assigns: %{user: user}} = conn, _params) do
    products = Diets.get_user_products(user.id)
    render(conn, "index.html", products: products)
  end
end
