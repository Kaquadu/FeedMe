defmodule FeedWeb.MealController do
  use FeedWeb, :controller

  def index(conn, %{"id" => diet_id}) do
    mealsets = Feed.Diets.get_diet_mealsets(diet_id)
    render(conn, "index.html", mealsets: mealsets)
  end
end
