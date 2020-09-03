defmodule Feed.Diets.Calculator do
  alias Feed.Combinations

  @max_portions 3
  @portions_step 0.5

  @fit_func_calories_coeff 10
  @fit_func_proteins_coeff 6
  @fit_func_carbs_coeff 6
  @fit_func_fats_coeff 6

  @empty_meal %{
    calories: 0,
    fats: 0,
    proteins: 0,
    carbs: 0
  }

  def calculate_meal(products, diet_stats) do
    products = products |> Enum.sort(&(&1.calories > &2.calories))

    calculate_best_combination(products, diet_stats)
  end

  defp calculate_best_combination(products, diet_stats) do
    k = length(products)

    portions = products |> prepare_products_portions()

    IO.inspect("Portions step")
    # |> Enum.reject(fn {_product, portion} -> portion == 0 end)

    combinations = portions |> get_all_products_combinations(k)

    IO.inspect("Combinations step")

    combinations = combinations |> reduce_doubles(k)

    IO.inspect("Remove doubles step")

    combinations
    |> get_best_meal({@empty_meal, :infinity}, diet_stats)
    |> humanize_result()
  end

  defp humanize_result({meal, fit_f_outome}) do
    %{
      ingridients: humanize_meal(meal),
      statistics: sum_meal_stats(meal),
      fit_function: %{
        score: fit_f_outome,
        fit_func_calories_coeff: @fit_func_calories_coeff,
        fit_func_proteins_coeff: @fit_func_proteins_coeff,
        fit_func_carbs_coeff: @fit_func_carbs_coeff,
        fit_func_fats_coeff: @fit_func_fats_coeff
      }
    }
  end

  defp humanize_meal(meal) do
    Enum.map(meal, fn {product, portion} ->
      {product, portion * 100}
    end)
  end

  defp get_best_meal([], {current_best, current_best_fit}, _diet_stats), do: {current_best, current_best_fit}

  defp get_best_meal([head | tail], {current_best, current_best_fit}, diet_stats) do
    fit = calculate_fit_function(head, diet_stats)
    if fit <= current_best_fit do
      get_best_meal(tail, {head, fit}, diet_stats)
    else
      get_best_meal(tail, {current_best, current_best_fit}, diet_stats)
    end
  end

  defp get_all_products_combinations(products_weights_list, k) do
    Combinations.combinations(products_weights_list, k)
  end

  defp reduce_doubles(meals_list, k) do
    Enum.map(meals_list, fn meal ->
      Enum.reduce(meal, %{}, fn {product, portion}, acc ->
        Map.put(acc, product.name, {product, portion})
      end)
    end)
    |> Enum.reject(fn meal_map ->
      Enum.count(meal_map) != k
    end)
    |> Enum.map(fn meal -> Enum.map(meal, fn {_name, rest} -> rest end) end)
  end

  def prepare_products_portions(products) do
    Enum.reduce(products, [], fn product, acc ->
       [get_single_product_portions(product, [], @portions_step) | acc]
    end)
    |> List.flatten()
  end

  def get_single_product_portions(_product, portions, current_portion)
      when current_portion > @max_portions do
    portions
  end

  def get_single_product_portions(product, portions, current_portion) do
    portions = [{product, current_portion} | portions]
    get_single_product_portions(product, portions, current_portion + @portions_step)
  end

  defp calculate_fit_function(products_portions_table, desired_meal) do
    products_portions_table
    |> sum_meal_stats()
    |> calculate_difference(desired_meal)
    |> calculate_diet_coeff()
  end

  defp sum_meal_stats(products_portions_table) do
    Enum.reduce(products_portions_table, @empty_meal, fn {product, portion}, meal_acc ->
      meal_acc
      |> Map.update!(:calories, &(&1 = meal_acc.calories + product.calories * portion))
      |> Map.update!(:fats, &(&1 = meal_acc.fats + product.fats * portion))
      |> Map.update!(:carbs, &(&1 = meal_acc.carbs + product.carbs * portion))
      |> Map.update!(:proteins, &(&1 = meal_acc.proteins + product.proteins * portion))
    end)
  end

  defp calculate_difference(current_meal, desired_meal) do
    %{
      calories_diff: abs(desired_meal.calories - current_meal.calories),
      carbs_diff: abs(desired_meal.carbs - current_meal.carbs),
      fats_diff: abs(desired_meal.fats - current_meal.fats),
      proteins_diff: abs(desired_meal.proteins - current_meal.proteins)
    }
  end

  defp calculate_diet_coeff(%{
    calories_diff: calories_diff,
    carbs_diff: carbs_diff,
    fats_diff: fats_diff,
    proteins_diff: proteins_diff
  }) do
    calories_diff * @fit_func_calories_coeff +
    carbs_diff * @fit_func_carbs_coeff +
    fats_diff * @fit_func_fats_coeff +
    proteins_diff * @fit_func_proteins_coeff
  end


end

defmodule Feed.Combinations do
  @doc """
  This function lists all combinations of `num` elements from the given `list`
  """
  def combinations(list, num)
  def combinations(_list, 0), do: [[]]
  def combinations(list = [], _num), do: list
  def combinations([head | tail], num) do
    Enum.map(combinations(tail, num - 1), &[head | &1]) ++ combinations(tail, num)
  end
end
