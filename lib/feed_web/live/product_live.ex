defmodule FeedWeb.ProductLive do
  use Phoenix.LiveView

  def render(assigns) do
    FeedWeb.ProductView.render("product_search.html", assigns)
  end

  def mount(_params, %{"user_session" => session}, socket) do
    changeset = Feed.ProductSearch.changeset(%Feed.ProductSearch{})
    {:ok, assign(socket, changeset: changeset, products: [], timestamp: :os.system_time(:millisecond), user_session: session)}
  end

  def handle_event("search", %{"product_search" => %{"query" => query}}, socket) do
    products = Feed.NutritionixApi.get_products(query)
    {:noreply, assign(socket, products: products, timestamp: :os.system_time(:millisecond))}
  end

  def handle_event("add_product", %{"product_search" => attrs}, socket) do
    Feed.Diets.upsert_product(attrs)
    {:noreply, assign(socket, timestamp: :os.system_time(:millisecond))}
  end

  def handle_event{_other, params, socket} do
    {:noreply, socket}
  end
end
