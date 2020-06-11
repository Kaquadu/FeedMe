defmodule Feed.Diets do
  import Ecto.Query

  alias Feed.Diets.Diet
  alias Feed.Diets.Meal
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

  def create_meal(attrs) do
    %Meal{}
    |> Meal.changeset(attrs)
    |> @repo.insert()
  end

  def get_user_meals(user_id) do
    @repo.all(Meal, user_id: user_id)
  end
end
