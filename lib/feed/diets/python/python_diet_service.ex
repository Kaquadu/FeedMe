defmodule Feed.PythonDietService do

  @min_portion 0.5
  @max_portion 3.5
  @macro_enhancement 20

  @empty_meal %{
    calories: 0,
    fats: 0,
    proteins: 0,
    carbs: 0
  }

  def calculate_meal(products, meal_stats) do
    result = call_python_optimization(products, meal_stats)

    ingridients = fetch_ingridients(result)

    statistics = calc_meal_stats(ingridients)

    result |> Map.replace!("ingridients", ingridients) |> Map.put("statistics", statistics) |> to_atom_map()
  end

  defp call_python_optimization(products, meal_stats) do
    products_json = prepare_products_json(products)
    meal_statistics_json = prepare_meal_statistics_json(meal_stats)

    {string_output, 0} = case length(products) do
      4 -> System.cmd("python3", ["/Users/mac/Desktop/Magisterka/FeedMe/feed/priv/python/calculate_diet_4.py", "#{products_json}", "#{meal_statistics_json}", "--lower_boundary=#{@min_portion}",  "--upper_boundary=#{@max_portion}", "--enhance=#{@macro_enhancement}"])
      6 -> System.cmd("python3", ["/Users/mac/Desktop/Magisterka/FeedMe/feed/priv/python/calculate_diet_6.py", "#{products_json}", "#{meal_statistics_json}", "--lower_boundary=#{@min_portion}",  "--upper_boundary=#{@max_portion}", "--enhance=#{@macro_enhancement}"])
      _ -> System.cmd("python3", ["/Users/mac/Desktop/Magisterka/FeedMe/feed/priv/python/calculate_diet_4.py", "#{products_json}", "#{meal_statistics_json}", "--lower_boundary=#{@min_portion}",  "--upper_boundary=#{@max_portion}", "--enhance=#{@macro_enhancement}"])
    end

    string_output
    |> String.split("<<<<SPLITTER>>>>")
    |> Enum.reverse()
    |> List.first()
    |> String.replace("\n", "")
    |> Jason.decode!()
  end

  defp fetch_ingridients(python_result) do
    python_result
    |> Map.get("ingridients")
    |> Enum.map(fn %{"id" => id, "weight" => weight} ->
      {Feed.Products.get_product_by_id(id), weight * 100}
    end)
  end

  defp calc_meal_stats(ingridients) do
    Enum.reduce(ingridients, @empty_meal, fn {product, portion}, meal_acc ->
      meal_acc
      |> Map.update!(:calories, &(&1 = meal_acc.calories + product.calories * portion / 100))
      |> Map.update!(:fats, &(&1 = meal_acc.fats + product.fats * portion / 100))
      |> Map.update!(:carbs, &(&1 = meal_acc.carbs + product.carbs * portion / 100))
      |> Map.update!(:proteins, &(&1 = meal_acc.proteins + product.proteins * portion / 100))
    end)
  end

  defp prepare_products_json(products) do
    Enum.reduce(products, %{}, fn prod, acc ->
      product_index = Enum.count(acc) + 1

      product_stats = %{
        "kcal" => Float.round(prod.calories, 0),
        "proteins" => Float.round(prod.proteins, 0),
        "carbs" => Float.round(prod.carbs),
        "fats" => Float.round(prod.fats, 0),
        "id" => prod.id
      }

      Map.put(acc, "product#{product_index}", product_stats)
    end) |> Jason.encode!()
  end

  defp prepare_meal_statistics_json(meal_stats) do
    %{
      "kcal" => Float.round(meal_stats.calories, 0),
      "proteins" => Float.round(meal_stats.proteins, 0),
      "carbs" => Float.round(meal_stats.carbs, 0),
      "fats" => Float.round(meal_stats.fats, 0)
    } |> Jason.encode!()
  end

  defp to_atom_map(map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      unless is_atom(k) do
        {String.to_atom(k), to_atom_map(v)}
      else
        {k, to_atom_map(v)}
      end
    end)
  end

  defp to_atom_map(v), do: v

  # Feed.Diets.Diet |> Feed.Repo.one |> Feed.Diets.MealsServingService.get_meals_from_diet
end
