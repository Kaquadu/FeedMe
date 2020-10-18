defmodule Feed.Diets do
  import Ecto.Query

  alias Ecto.Multi
  alias Feed.Diets.Diet
  alias Feed.Diets.Meal
  alias Feed.Diets.Mealset
  alias Feed.Diets.MealsServingService
  alias Feed.Workers.DietsWorker
  @repo Feed.Repo

  @proteins_kcal 4
  @carbs_kcal 4
  @fats_kcal 9

  @standard_diet %{
    fats: 0.3,
    carbs: 0.55,
    proteins: 0.15
  }

  @protein_diet %{
    fats: 0.25,
    carbs: 0.50,
    proteins: 0.25
  }

  @carbs_reduce_diet %{
    fats: 0.35,
    carbs: 0.4,
    proteins: 0.25
  }

  defdelegate upsert_product(attrs), to: Feed.Products, as: :upsert_product
  defdelegate get_user_products(user_id, name \\ ""), to: Feed.Products, as: :get_user_products
  defdelegate get_product_by_id(id), to: Feed.Products, as: :get_product_by_id
  defdelegate delete_product(product), to: Feed.Products, as: :delete_product
  defdelegate update_product(product, params), to: Feed.Products, as: :update_product

  def create_diet(attrs) do
    %Diet{}
    |> Diet.changeset(attrs)
    |> @repo.insert()
  end

  def generate_diet(%{
    "name" => name,
    "age" => age,
    "gender" => gender,
    "height" => height,
    "weight" => weight,
    "activity" => activity_factor,
    "mass_type" => mass_type,
    "diet_type" => diet_type,
    "user_id" => user_id
  }) do
    with  {age, ""} <- Integer.parse(age),
          {height, ""} <- Integer.parse(height),
          {weight, ""} <- Integer.parse(weight),
          {activity_factor, ""} <- Float.parse(activity_factor)
    do
      calories = case gender do
        "female" -> (10 * weight + 6.25 * height - 5 * age - 161) * activity_factor
        "male" -> (10 * weight + 6.25 * height - 5 * age + 5) * activity_factor
      end

      calories = case mass_type do
        "balanced" -> calories
        "mass_loss" -> calories - 400
        "mass_gain" -> calories + 400
      end

      proteins = case diet_type do
        "balanced" -> calories * @standard_diet.proteins / @proteins_kcal
        "proteins" -> calories * @protein_diet.proteins / @proteins_kcal
        "carb_reduction" -> calories * @carbs_reduce_diet.proteins / @proteins_kcal
      end

      carbs = case diet_type do
        "balanced" -> calories * @standard_diet.carbs / @carbs_kcal
        "proteins" -> calories * @protein_diet.carbs / @carbs_kcal
        "carb_reduction" -> calories * @carbs_reduce_diet.carbs / @carbs_kcal
      end

      fats = case diet_type do
        "balanced" -> calories * @standard_diet.fats / @fats_kcal
        "proteins" -> calories * @protein_diet.fats / @fats_kcal
        "carb_reduction" -> calories * @carbs_reduce_diet.fats / @fats_kcal
      end

      no_big_meals = if activity_factor >= 2.0, do: 2, else: 1
      no_small_meals = if activity_factor >= 2.0, do: 3, else: 4

      diet_params = %{
        name: name,
        calories: round(calories),
        proteins: round(proteins),
        carbs: round(carbs),
        fats: round(fats),
        no_big_meals: no_big_meals,
        no_small_meals: no_small_meals,
        user_id: user_id
      }

      create_diet(diet_params)
    else
      _err -> {:error, "Inproper values"}
    end
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

  def get_diets(), do: @repo.all(Diet)

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

      ingridients = Enum.map(ingridients, fn {product, weight} ->
        %{name: product.name, calories: product.calories, fats: product.fats, carbs: product.carbs, proteins: product.proteins, weight: weight}
      end)

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
    |> preload([:diet, {:meals, [:breakfast_ingridients, :dinner_ingridients, :other_ingridients]}])
    |> @repo.all()
  end

  def get_diet_statistics!(diet_id) do
    try do
      average_statistics = get_average_statistics(diet_id)
      daily_statistics = get_daily_statistics(diet_id)
      %{
        daily: daily_statistics,
        average: average_statistics
      }
    catch
      _err -> :error
    end
  end

  defp get_average_statistics(diet_id) do
    query = """
        SELECT AVG(kcalSum), AVG(fatsSum), AVG(carbsSum), AVG(proteinsSum), AVG(desiredKcalSum), AVG(desiredFatsSum), AVG(desiredCarbsSum), AVG(desiredProteinsSum)  FROM
        (
          SELECT
            SUM(diet_meals.calculated_calories) / COUNT(DISTINCT diet_mealsets.id) AS kcalSum,
            SUM(diet_meals.calculated_fats) / COUNT(DISTINCT diet_mealsets.id) AS fatsSum,
            SUM(diet_meals.calculated_carbs) / COUNT(DISTINCT diet_mealsets.id) AS carbsSum,
            SUM(diet_meals.calculated_proteins) / COUNT(DISTINCT diet_mealsets.id) AS proteinsSum,
            SUM(diet_meals.desired_calories) / COUNT(DISTINCT diet_mealsets.id) AS desiredKcalSum,
            SUM(diet_meals.desired_fats) / COUNT(DISTINCT diet_mealsets.id) AS desiredFatsSum,
            SUM(diet_meals.desired_carbs) / COUNT(DISTINCT diet_mealsets.id) AS desiredCarbsSum,
            SUM(diet_meals.desired_proteins) / COUNT(DISTINCT diet_mealsets.id) AS desiredProteinsSum
          FROM diet_meals
          INNER JOIN diet_mealsets ON diet_meals.mealset_id = diet_mealsets.id
          GROUP BY diet_mealsets.id
          HAVING diet_mealsets.diet_id = $1
          ORDER BY diet_mealsets.inserted_at DESC
        ) AS dietSums LIMIT 30;
      """

      {:ok, binary_id} = Ecto.UUID.dump(diet_id)
      {:ok, %{rows: [[kcal, fats, carbs, proteins, desired_kcal, desired_fats, desired_carbs, desired_proteins]]}} = Ecto.Adapters.SQL.query(@repo, query, [binary_id])

      %{
        served: %{
          calories: kcal,
          fats: fats,
          carbs: carbs,
          proteins: proteins
        },
        desired: %{
          calories: desired_kcal,
          fats: desired_fats,
          carbs: desired_carbs,
          proteins: desired_proteins
        }
      }
  end

  def get_daily_statistics(diet_id) do
    (from m in Meal, as: :meal)
    |> join(:inner, [meal: m], ms in assoc(m, :mealset), as: :mealset)
    |> where([mealset: ms], ms.diet_id == ^diet_id)
    |> order_by([mealset: ms], [desc: ms.inserted_at, asc: ms.id])
    |> group_by([meal: m, mealset: ms], [m.mealset_id, ms.inserted_at, ms.id])
    |> limit(30)
    |> select(
      [meal: m, mealset: ms],
      %{
        day: ms.day,
        calories: sum(m.calculated_calories),
        fats: sum(m.calculated_fats),
        carbs: sum(m.calculated_carbs),
        proteins: sum(m.calculated_carbs)
      }
    )
    |> @repo.all()
    |> Enum.map(fn data ->
      Map.put(data, :day, Date.to_iso8601(data.day))
    end)
  end
end
