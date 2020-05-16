defmodule FeedWeb.ProductLive do
  use Phoenix.LiveView

  def render(assigns) do
    FeedWeb.ProductView.render("product_search.html", assigns)
  end

  def mount(params, attrs, socket) do
    IO.inspect({attrs, params}, label: "mount")
    changeset = Feed.ProductSearch.changeset(%Feed.ProductSearch{})
    {:ok, assign(socket, changeset: changeset, products: [])}
  end

  def handle_event("search", %{"product_search" => %{"query" => query}}, socket) do
    products = Feed.NutritionixApi.get_products(query)
    {:noreply, assign(socket, products: products)}
  end

  def handle_event{_other, params, socket} do
    IO.inspect params
    {:noreply, socket}
  end
end
