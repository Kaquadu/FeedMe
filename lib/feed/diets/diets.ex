defmodule Feed.Diets do
  import Ecto.Query

  alias Ecto.Multi
  alias Feed.Diets.Diet
  alias Feed.Diets.Meal
  alias Feed.Diets.Mealset
  alias Feed.Diets.MealsServingService
  alias Feed.Workers.DietsWorker
  @repo Feed.Repo

  defdelegate upsert_product(attrs), to: Feed.Products, as: :upsert_product
  defdelegate get_user_products(user_id, name \\ ""), to: Feed.Products, as: :get_user_products
  defdelegate get_product_by_id(id), to: Feed.Products, as: :get_product_by_id
  defdelegate delete_product(product), to: Feed.Products, as: :delete_product

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
    (from d in Diet, as: :diet)
    |> where([diet: d], d.user_id == ^user_id)
    |> preload([:mealsets])
    |> @repo.all()
  end

  def get_diet(diet_id), do: @repo.get_by(Diet, id: diet_id)

  def request_daily_meals(diet_id) do
    diet_id
    |> check_diet_queue()
    |> check_mealsets()
    |> case do
      {:error, reason} -> {:error, reason}
      diet_id -> DietsWorker.insert_diet_request(diet_id)
    end
  end

  defp check_diet_queue(diet_id) do
    if DietsWorker.check_diet(diet_id) != [] do
      {:error, "Already enqueued"}
    else
      diet_id
    end
  end

  defp check_mealsets({:error, _} = error), do: error

  defp check_mealsets(diet_id) do
    tomorrow = Date.utc_today() |> Timex.shift(days: 1)

    (from m in Mealset, as: :mealset)
    |> where([mealset: m], m.diet_id == ^diet_id)
    |> where([mealset: m], m.day == ^tomorrow)
    |> @repo.exists?()
    |> if do
      {:error, "Already calculated"}
    else
      diet_id
    end
  end

  def get_daily_meals(diet_id) do
    try do
      diet = get_diet(diet_id)
      todays_meals = MealsServingService.get_meals_from_diet(diet)

      DietsWorker.complete_diet_request(diet_id)

      Multi.new()
      |> Multi.run(:create_mealset, create_mealset_step(diet))
      |> Multi.run(:add_meals, add_meals_step(todays_meals))
      |> @repo.transaction()
    rescue
      e ->
        IO.inspect e
        DietsWorker.complete_diet_request(diet_id)
        raise RuntimeError, message: "Something went wrong while calculating the meals"
    end
  end

  defp create_mealset_step(diet) do
    fn repo, _ ->
      %Mealset{}
      |> Mealset.changeset(%{diet_id: diet.id, user_id: diet.user_id, day: Timex.shift(Date.utc_today(), days: 1)})
      |> repo.insert()
    end
  end

  defp add_meals_step(%{breakfast: breakfast, dinner: dinner, small_meals: small_meals, big_meals: big_meals} = _meals) do
    fn repo, %{create_mealset: mealset} = _previous ->
      all_meals = [breakfast] ++ [dinner] ++ small_meals ++ big_meals
      Enum.map(all_meals, fn meal ->
        meal
        |> prepare_meal_changeset(mealset)
        |> repo.insert!()
      end)
      |> Enum.any?(fn status -> status == :error end)
      |> if do
        {:error, mealset}
      else
        {:ok, mealset}
      end
    end
  end

  defp prepare_meal_changeset(
    %{
      calculated: %{
        ingridients: ingridients,
        statistics: %{
          calories: calculated_calories,
          fats: calculated_fats,
          carbs: calculated_carbs,
          proteins: calculated_proteins
        },
        fit_function: %{
          score: fit_function_result,
          fit_func_calories_coeff: coeff_calories,
          fit_func_proteins_coeff: coeff_proteins,
          fit_func_carbs_coeff: coeff_carbs,
          fit_func_fats_coeff: coeff_fats
        }
      },
      desired: %{
        calories: desired_calories,
        fats: desired_fats,
        carbs: desired_carbs,
        proteins: desired_proteins
      }},
    %{id: mealset_id, user_id: user_id} = _mealset) do

      {product, _} = List.first(ingridients)

      ingridients = Enum.map(ingridients, fn {product, weight} -> %{product_id: product.id, weight: weight} end)

      ingridients_data =
        case product.__meta__.source do
          "breakfast_products" -> %{breakfast_ingridients: ingridients}
          "dinner_products" -> %{dinner_ingridients: ingridients}
          "other_products" -> %{other_ingridients: ingridients}
        end


      params = %{
        desired_calories: desired_calories,
        desired_fats: desired_fats,
        desired_carbs: desired_carbs,
        desired_proteins: desired_proteins,
        calculated_calories: calculated_calories,
        calculated_fats: calculated_fats,
        calculated_carbs: calculated_carbs,
        calculated_proteins: calculated_proteins,
        mealset_id: mealset_id,
        user_id: user_id,
        meal_statistics: %{
          fit_function_result: fit_function_result,
          coeff_calories: coeff_calories,
          coeff_proteins: coeff_proteins,
          coeff_carbs: coeff_carbs,
          coeff_fats: coeff_fats
        }
      } |> Map.merge(ingridients_data)

      Feed.Diets.Meal.changeset(%Meal{}, params)
  end

  def create_meal(attrs) do
    %Meal{}
    |> Meal.changeset(attrs)
    |> @repo.insert()
  end

  def get_user_meals(user_id) do
    @repo.all(Meal, user_id: user_id)
  end

  def get_diet_mealsets(diet_id) do
    Mealset
    |> where([m], m.diet_id == ^diet_id)
    |> order_by([m], [desc: m.inserted_at, asc: m.id])
    |> limit(30)
    |> preload([:diet, {:meals, [{:breakfast_ingridients, :product}, {:dinner_ingridients, :product}, {:other_ingridients, :product}]}])
    |> @repo.all()
  end
end
