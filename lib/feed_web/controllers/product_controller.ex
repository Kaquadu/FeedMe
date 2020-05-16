defmodule FeedWeb.ProductController do
  use FeedWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
