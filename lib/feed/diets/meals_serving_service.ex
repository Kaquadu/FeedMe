defmodule Feed.Diets.MealsServingService do
  alias Feed.Diets
  alias Feed.Diets.Meal
  alias Feed.Diets.Product

  @repo Feed.Repo

  @big_meal_portions 7
  @small_meal_portions 4

  @big_meal_products 6
  @small_meal_products 4

  def get_meals_from_diet(diet) do
    diet
    |> get_meals_stats()
    |> calculate_meals()
  end

  defp get_meals_stats(diet) do
    calories_portion = diet.calories / (diet.no_big_meals * @big_meal_portions + diet.no_small_meals * @small_meal_portions)
    fats_portion = diet.fats / (diet.no_big_meals * @big_meal_portions + diet.no_small_meals * @small_meal_portions)
    carbs_portion = diet.carbs / (diet.no_big_meals * @big_meal_portions + diet.no_small_meals * @small_meal_portions)
    proteins_portion = diet.proteins / (diet.no_big_meals * @big_meal_portions + diet.no_small_meals * @small_meal_portions)

    big_meal_kcal = calories_portion * @big_meal_portions
    small_meal_kcal = calories_portion * @small_meal_portions

    {diet, %{
      big_meal: big_meal_kcal,
      small_meal: small_meal_kcal
    }}
  end

  defp calculate_meals({diet, meal_stats}) do

  end
end
