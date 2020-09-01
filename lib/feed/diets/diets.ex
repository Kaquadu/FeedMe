defmodule Feed.Diets do
  import Ecto.Query

  alias Feed.Diets.Diet
  alias Feed.Diets.Meal
  alias Feed.Diets.MealsServingService
  alias Feed.Workers.DietsWorker
  @repo Feed.Repo

  defdelegate upsert_product(attrs), to: Feed.Products, as: :upsert_product
  defdelegate get_user_products(user_id), to: Feed.Products, as: :get_user_products

  def create_diet(attrs) do
    %Diet{}
    |> Diet.changeset(attrs)
    |> @repo.insert()
  end

  def delete_diet(id) do
    Diet
    |> where([d], d.id == ^id)
    |> @repo.delete_all()
  end

  def get_user_diets(user_id) do
    @repo.all(Diet, user_id: user_id)
  end

  def get_diet(diet_id), do: @repo.get_by(Diet, id: diet_id)

  def request_daily_meals(diet_id) do
    DietsWorker.insert_diet_request(diet_id)
  end

  def get_daily_meals(diet_id) do
    try do
      diet = get_diet(diet_id)
      todays_meals = MealsServingService.get_meals_from_diet(diet)

      DietsWorker.complete_diet_request(diet_id)

      %{
        diet: diet,
        todays_meals: todays_meals
      }
    rescue
      e ->
        IO.inspect e
        DietsWorker.complete_diet_request(diet_id)
        raise RuntimeError, message: "Something went wrong while calculating the meals"
    end
  end

  def create_meal(attrs) do
    %Meal{}
    |> Meal.changeset(attrs)
    |> @repo.insert()
  end

  def get_user_meals(user_id) do
    @repo.all(Meal, user_id: user_id)
  end
end
