alias Feed.Repo
import Ecto.Query

user_id = Feed.Auth.User |> Repo.one() |> Map.get(:id)

products = Feed.Products.get_user_random_products(5, "dinner", user_id)

sample_diet = %{calories: 2000, fats: 150, carbs: 150, proteins: 150}

IO.inspect("Alg start")
IO.inspect(Feed.Diets.Calculator.calculate_meal(products, sample_diet))
