defmodule Feed.Diets.MealsServingService do
  alias Feed.Products
  alias Feed.Diets.Calculator

  @big_meal_portions 9
  @small_meal_portions 5

  @big_meal_no_products 6
  @small_meal_no_products 4

  def get_meals_from_diet(diet) do
    diet
    |> get_meals_stats()
    |> calculate_meals(diet)
  end

  defp get_meals_stats(diet) do
    calories_portion = diet.calories / (diet.no_big_meals * @big_meal_portions + diet.no_small_meals * @small_meal_portions)
    fats_portion = diet.fats / (diet.no_big_meals * @big_meal_portions + diet.no_small_meals * @small_meal_portions)
    carbs_portion = diet.carbs / (diet.no_big_meals * @big_meal_portions + diet.no_small_meals * @small_meal_portions)
    proteins_portion = diet.proteins / (diet.no_big_meals * @big_meal_portions + diet.no_small_meals * @small_meal_portions)

    big_meal_kcal = calories_portion * @big_meal_portions
    small_meal_kcal = calories_portion * @small_meal_portions

    big_meal_fats = fats_portion * @big_meal_portions
    small_meal_fats = fats_portion * @small_meal_portions

    big_meal_carbs = carbs_portion * @big_meal_portions
    small_meal_carbs = carbs_portion * @small_meal_portions

    big_meal_proteins = proteins_portion * @big_meal_portions
    small_meal_proteins = proteins_portion * @small_meal_portions

    %{
      small_meal: %{
        calories: small_meal_kcal,
        fats: small_meal_fats,
        carbs: small_meal_carbs,
        proteins: small_meal_proteins
      },
      big_meal: %{
        calories: big_meal_kcal,
        fats: big_meal_fats,
        carbs: big_meal_carbs,
        proteins: big_meal_proteins
      }
    }
  end

  defp calculate_meals(%{big_meal: big_meal_stats, small_meal: small_meal_stats} = meals_stats, diet) do
    %{
      breakfast: %{calculated: get_breakfast(small_meal_stats, diet.user_id), desired: small_meal_stats},
      dinner: %{calculated: get_dinner(big_meal_stats, diet.user_id), desired: big_meal_stats},
      big_meals: get_big_meals(meals_stats, diet),
      small_meals: get_small_meals(meals_stats, diet)
    }
  end

  defp get_breakfast(breakfast_stats, user_id) do
    @small_meal_no_products
    |> Products.get_user_random_products("breakfast", user_id)
    |> calculate_portion(breakfast_stats)
  end

  defp get_dinner(dinner_stats, user_id) do
    @big_meal_no_products
    |> Products.get_user_random_products("dinner", user_id)
    |> calculate_portion(dinner_stats)
  end

  defp get_big_meals(%{big_meal: meal_stats}, diet) do
    append_meal(meal_stats, diet, [], :big)
  end

  defp get_small_meals(%{small_meal: meal_stats}, diet) do
    append_meal(meal_stats, diet, [], :small)
  end

  defp append_meal(meal_stats, diet, current_meals, :big) do
    if (current_meals |> length()) >= (diet.no_big_meals) do
      current_meals
    else
      current_meals = [%{calculated: get_other_big_meal(meal_stats, diet.user_id), desired: meal_stats} | current_meals]
      append_meal(meal_stats, diet, current_meals, :big)
    end
  end

  defp append_meal(meal_stats, diet, current_meals, :small) do
    if (current_meals |> length()) >= (diet.no_small_meals) do
      current_meals
    else
      current_meals = [%{calculated: get_other_small_meal(meal_stats, diet.user_id), desired: meal_stats} | current_meals]
      append_meal(meal_stats, diet, current_meals, :big)
    end
  end

  defp get_other_big_meal(meal_stats, user_id) do
    @big_meal_no_products
    |> Products.get_user_random_products("other", user_id)
    |> calculate_portion(meal_stats)
  end

  defp get_other_small_meal(meal_stats, user_id) do
    @small_meal_no_products
    |> Products.get_user_random_products("other", user_id)
    |> calculate_portion(meal_stats)
  end

  defp calculate_portion(products, meal_stats) do
    # Calculator.calculate_meal(products, meal_stats)
    Feed.PythonDietService.calculate_meal(products, meal_stats)
  end
end
