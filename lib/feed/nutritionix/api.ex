defmodule Feed.NutritionixApi do
  @base_url "https://trackapi.nutritionix.com/v2"
  @headers [
    {"x-app-id", "3391cfa2"},
    {"x-app-key", "a1cd8df1c630bbae2fb41b2755e1d3cc"},
    {"Content-Type", "application/json"},
    {"Accent", "application/json"}
  ]
  @products_url "/natural/nutrients"

  def get_products(query) do
    url = @base_url <> @products_url
    body = %{
      "query" => query
     } |> Jason.encode!()

    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    {:ok, response} = HTTPoison.post(url, body, @headers, options)

    response.body |> Jason.decode!()
  end
end
