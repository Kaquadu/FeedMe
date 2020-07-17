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
    query
    |> get_response()
    |> prepare_data()
  end

  defp get_response(query) do
    url = @base_url <> @products_url
    body = %{
      "query" => query
     } |> Jason.encode!()

    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    {:ok, response} = HTTPoison.post(url, body, @headers, options)

    response.body |> Jason.decode!() |> Map.get("foods")
  end

  defp prepare_data(products) do
    Enum.map(products, fn product ->
      %{
        name: Map.get(product, "food_name"),
        calories: calculate_attr(product, "nf_calories"),
        fats: calculate_attr(product, "nf_total_fat"),
        proteins: calculate_attr(product, "nf_protein"),
        carbs: calculate_attr(product, "nf_total_carbohydrate"),
        photo: product |> Map.get("photo") |> Map.get("highres")
      }
    end)
  end

  defp calculate_attr(%{"serving_weight_grams" => weight} = product, attribute) do
    attribute_quantity = Map.get(product, attribute)
    (attribute_quantity / weight) * 100
  end
end
