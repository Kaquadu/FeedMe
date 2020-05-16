defmodule FeedWeb.ProductLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      Rendered: <%= @rendered %>
    """
  end

  def mount(params, attrs, socket) do
    params |> IO.inspect
    attrs |> IO.inspect
    {:ok, assign(socket, :rendered, true)}
  end
end
