defmodule Feed.Nutritionix.Api do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://trackapi.nutritionix.com/v2"
  plug Tesla.Middleware.Headers, [
    {"x-app-id", "3391cfa2"},
    {"x-app-key", "a1cd8df1c630bbae2fb41b2755e1d3cc"},
    {"Content-Type", "application/json"}
  ]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.MethodOverride, :post

  @nutrients_url "/natural/nutrients"

  def get_nutrients(query) do
    post(@nutrients_url, query)
  end

end
