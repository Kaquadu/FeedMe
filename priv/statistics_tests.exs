defmodule FeedStatistics do
  import Ecto.Query

  @repo Feed.Repo

  @big_meal_stats %{
    calories: 1000.0,
    carbs: 450.0 / 4.0,
    fats: 350.0 / 9.0,
    proteins: 200.0 / 4.0
  }

  @small_meal_stats %{
    calories: 500.0,
    carbs: 225.0 / 4.0,
    fats: 175.0 / 9.0,
    proteins: 100.0 / 4.0
  }

  @enhance_list [0, 2, 5, 10, 20, 35, 50]

  def create_statistics(number) do
    %{
      small_meals_stats: calculate_meals_stats(:small_meal, number),
      big_meals_stats: calculate_meals_stats(:big_meal, number)
    }
  end

  defp calculate_meals_stats(type, number) do
    %{}
    |> append_stats(0, number, type)
    |> calculate_math_stats(type)
  end

  defp append_stats(result, current_number, total_number, _) when current_number == total_number, do: result

  defp append_stats(result, current_number, total_number, meal_type) do
    products = case meal_type do
      :small_meal -> random_products(4)
      :big_meal -> random_products(6)
    end

    result_for_products = Enum.reduce(@enhance_list, result, fn enhance, acc ->
      meal_stats = case meal_type do
        :small_meal -> @small_meal_stats
        :big_meal -> @big_meal_stats
      end
      %{statistics: statistics} = Feed.PythonDietService.calculate_meal(products, meal_stats, enhance)

      {_, acc} =
        Map.get_and_update(acc, "#{enhance}", fn current_stats ->
          if current_stats, do: {current_stats, [statistics | current_stats]}, else: {current_stats, [statistics]} end)

      acc
    end)
    append_stats( result_for_products, current_number + 1, total_number, meal_type )
  end

  defp random_products(number) do
    (from m in {"other_products", Feed.Diets.Product})
    |> @repo.all()
    |> Enum.take_random(number)
  end

  defp calculate_math_stats(overall_stats, type) do
    Enum.reduce(overall_stats, %{}, fn {enhance, list_of_stats}, acc ->
      calories = Enum.map(list_of_stats, fn %{calories: calories} -> calories end)
      fats = Enum.map(list_of_stats, fn %{fats: fats} -> fats end)
      carbs = Enum.map(list_of_stats, fn %{carbs: carbs} -> carbs end)
      proteins = Enum.map(list_of_stats, fn %{proteins: proteins} -> proteins end)

      calories_differences = Enum.map(list_of_stats, fn %{calories: calories} ->
        case type do
          :small_meal -> Statistics.Math.abs(calories - @small_meal_stats.calories)
          :big_meal -> Statistics.Math.abs(calories - @big_meal_stats.calories)
        end
      end)

      fats_differences = Enum.map(list_of_stats, fn %{fats: fats} ->
        case type do
          :small_meal -> Statistics.Math.abs(fats - @small_meal_stats.fats)
          :big_meal -> Statistics.Math.abs(fats - @big_meal_stats.fats)
        end
      end)

      carbs_differences = Enum.map(list_of_stats, fn %{carbs: carbs} ->
        case type do
          :small_meal -> Statistics.Math.abs(carbs - @small_meal_stats.carbs)
          :big_meal -> Statistics.Math.abs(carbs - @big_meal_stats.carbs)
        end
      end)

      proteins_differences = Enum.map(list_of_stats, fn %{proteins: proteins} ->
        case type do
          :small_meal -> Statistics.Math.abs(proteins - @small_meal_stats.proteins)
          :big_meal -> Statistics.Math.abs(proteins - @big_meal_stats.proteins)
        end
      end)

      stats = %{
        calories: %{
          stdev: Statistics.stdev(calories),
          median: Statistics.median(calories),
          avg: Statistics.mean(calories),
          avg_difference: Statistics.stdev(calories_differences)
        },

        fats: %{
          stdev: Statistics.stdev(fats),
          median: Statistics.median(fats),
          avg: Statistics.mean(fats),
          avg_difference: Statistics.stdev(fats_differences)
        },

        carbs: %{
          stdev: Statistics.stdev(carbs),
          median: Statistics.median(carbs),
          avg: Statistics.mean(carbs),
          avg_difference: Statistics.stdev(carbs_differences)
        },

        proteins: %{
          stdev: Statistics.stdev(proteins),
          median: Statistics.median(proteins),
          avg: Statistics.mean(proteins),
          avg_difference: Statistics.stdev(proteins_differences)
        }
      }

      Map.put(acc, enhance, stats)
    end)
  end

  def enhance_list(), do: @enhance_list

  def small_meal_stats(), do: @small_meal_stats


  def big_meal_stats(), do: @big_meal_stats
end

%{
  small_meals_stats: small_meals_stats,
  big_meals_stats: big_meals_stats
} = FeedStatistics.create_statistics(50)

small_products_calories_means = small_meals_stats |> Enum.map(fn {_enhance, %{calories: %{avg: avg}}} -> avg end)
small_products_calories_stdevs = small_meals_stats |> Enum.map(fn {_enhance, %{calories: %{stdev: stdev}}} -> stdev end)

x_ticks = FeedStatistics.enhance_list()

Expyplot.Plot.figure()
Expyplot.Plot.bar(x_ticks, small_products_calories_means, [width: 1.0, color: "lightcoral"], yerr: small_products_calories_stdevs, label: "Average calories", ecolor: "black", capsize: 5)
Expyplot.Plot.xticks([x_ticks, FeedStatistics.enhance_list()])
Expyplot.Plot.ylabel("Kalorie")
Expyplot.Plot.xlabel("Wzmocnienie")
Expyplot.Plot.axhline([y: FeedStatistics.small_meal_stats().calories])
Expyplot.Plot.title("Srednia ilosc kalorii dla wzmocnienia - male posilki")
# Expyplot.Plot.yticks([y_ticks])
Expyplot.Plot.grid(b: true)

small_products_fats_means = small_meals_stats |> Enum.map(fn {_enhance, %{fats: %{avg: avg}}} -> avg end)
small_products_fats_stdevs = small_meals_stats |> Enum.map(fn {_enhance, %{fats: %{stdev: stdev}}} -> stdev / 3 end)

Expyplot.Plot.figure()
Expyplot.Plot.bar(x_ticks, small_products_fats_means, [width: 1.0, color: "lightcoral"], yerr: small_products_fats_stdevs, label: "Average fats", ecolor: "black", capsize: 5)
Expyplot.Plot.xticks([x_ticks, FeedStatistics.enhance_list()])
Expyplot.Plot.ylabel("Tluszcze")
Expyplot.Plot.xlabel("Wzmocnienie")
Expyplot.Plot.axhline([y: FeedStatistics.small_meal_stats().fats])
Expyplot.Plot.title("Srednia ilosc tluszczy dla wzmocnienia - male posilki")
# Expyplot.Plot.yticks([y_ticks_2])
Expyplot.Plot.grid(b: true)

small_products_carbs_means = small_meals_stats |> Enum.map(fn {_enhance, %{carbs: %{avg: avg}}} -> avg end)
small_products_carbs_stdevs = small_meals_stats |> Enum.map(fn {_enhance, %{carbs: %{stdev: stdev}}} -> stdev / 3 end)

Expyplot.Plot.figure()
Expyplot.Plot.bar(x_ticks, small_products_carbs_means, [width: 1.0, color: "lightcoral"], yerr: small_products_carbs_stdevs, label: "Average carbs", ecolor: "black", capsize: 5)
Expyplot.Plot.xticks([x_ticks, FeedStatistics.enhance_list()])
Expyplot.Plot.ylabel("Weglowodany")
Expyplot.Plot.xlabel("Wzmocnienie")
Expyplot.Plot.axhline([y: FeedStatistics.small_meal_stats().carbs])
Expyplot.Plot.title("Srednia ilosc weglowodanow dla wzmocnienia - male posilki")
# Expyplot.Plot.yticks([y_ticks_2])
Expyplot.Plot.grid(b: true)

small_products_proteins_means = small_meals_stats |> Enum.map(fn {_enhance, %{proteins: %{avg: avg}}} -> avg end)
small_products_proteins_stdevs = small_meals_stats |> Enum.map(fn {_enhance, %{proteins: %{stdev: stdev}}} -> stdev / 3 end)

Expyplot.Plot.figure()
Expyplot.Plot.bar(x_ticks, small_products_proteins_means, [width: 1.0, color: "lightcoral"], yerr: small_products_proteins_stdevs, label: "Average proteins", ecolor: "black", capsize: 5)
Expyplot.Plot.xticks([x_ticks, FeedStatistics.enhance_list()])
Expyplot.Plot.ylabel("Bialka")
Expyplot.Plot.xlabel("Wzmocnienie")
Expyplot.Plot.axhline([y: FeedStatistics.small_meal_stats().proteins])
Expyplot.Plot.title("Srednia ilosc bialek dla wzmocnienia - male posilki")
# Expyplot.Plot.yticks([y_ticks_2])
Expyplot.Plot.grid(b: true)


big_products_calories_means = big_meals_stats |> Enum.map(fn {_enhance, %{calories: %{avg: avg}}} -> avg end)
big_products_calories_stdevs = big_meals_stats |> Enum.map(fn {_enhance, %{calories: %{stdev: stdev}}} -> stdev end)

Expyplot.Plot.figure()
Expyplot.Plot.bar(x_ticks, big_products_calories_means, [width: 1.0, color: "lightcoral"], yerr: big_products_calories_stdevs, label: "Average calories", ecolor: "black", capsize: 5)
Expyplot.Plot.xticks([x_ticks, FeedStatistics.enhance_list()])
Expyplot.Plot.ylabel("Kalorie")
Expyplot.Plot.xlabel("Wzmocnienie")
Expyplot.Plot.axhline([y: FeedStatistics.big_meal_stats().calories])
Expyplot.Plot.title("Srednia ilosc kalorii dla wzmocnienia - duze posilki")
# Expyplot.Plot.yticks([y_ticks])
Expyplot.Plot.grid(b: true)

big_products_fats_means = big_meals_stats |> Enum.map(fn {_enhance, %{fats: %{avg: avg}}} -> avg end)
big_products_fats_stdevs = big_meals_stats |> Enum.map(fn {_enhance, %{fats: %{stdev: stdev}}} -> stdev / 3 end)

Expyplot.Plot.figure()
Expyplot.Plot.bar(x_ticks, big_products_fats_means, [width: 1.0, color: "lightcoral"], yerr: big_products_fats_stdevs, label: "Average fats", ecolor: "black", capsize: 5)
Expyplot.Plot.xticks([x_ticks, FeedStatistics.enhance_list()])
Expyplot.Plot.ylabel("Tluszcze")
Expyplot.Plot.xlabel("Wzmocnienie")
Expyplot.Plot.axhline([y: FeedStatistics.big_meal_stats().fats])
Expyplot.Plot.title("Srednia ilosc tluszczy dla wzmocnienia - duze posilki")
# Expyplot.Plot.yticks([y_ticks_2])
Expyplot.Plot.grid(b: true)

big_products_carbs_means = big_meals_stats |> Enum.map(fn {_enhance, %{carbs: %{avg: avg}}} -> avg end)
big_products_carbs_stdevs = big_meals_stats |> Enum.map(fn {_enhance, %{carbs: %{stdev: stdev}}} -> stdev / 3 end)

Expyplot.Plot.figure()
Expyplot.Plot.bar(x_ticks, big_products_carbs_means, [width: 1.0, color: "lightcoral"], yerr: big_products_carbs_stdevs, label: "Average carbs", ecolor: "black", capsize: 5)
Expyplot.Plot.xticks([x_ticks, FeedStatistics.enhance_list()])
Expyplot.Plot.ylabel("Weglowodany")
Expyplot.Plot.xlabel("Wzmocnienie")
Expyplot.Plot.axhline([y: FeedStatistics.big_meal_stats().carbs])
Expyplot.Plot.title("Srednia ilosc weglowodanow dla wzmocnienia - duze posilki")
# Expyplot.Plot.yticks([y_ticks_2])
Expyplot.Plot.grid(b: true)

big_products_proteins_means = big_meals_stats |> Enum.map(fn {_enhance, %{proteins: %{avg: avg}}} -> avg end)
big_products_proteins_stdevs = big_meals_stats |> Enum.map(fn {_enhance, %{proteins: %{stdev: stdev}}} -> stdev / 3 end)

Expyplot.Plot.figure()
Expyplot.Plot.bar(x_ticks, big_products_proteins_means, [width: 1.0, color: "lightcoral"], yerr: big_products_proteins_stdevs, label: "Average proteins", ecolor: "black", capsize: 5)
Expyplot.Plot.xticks([x_ticks, FeedStatistics.enhance_list()])
Expyplot.Plot.ylabel("Bialka")
Expyplot.Plot.xlabel("Wzmocnienie")
Expyplot.Plot.axhline([y: FeedStatistics.big_meal_stats().proteins])
Expyplot.Plot.title("Srednia ilosc bialek dla wzmocnienia - duze posilki")
# Expyplot.Plot.yticks([y_ticks_2])
Expyplot.Plot.grid(b: true)


Expyplot.Plot.show()
