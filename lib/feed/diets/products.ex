defmodule Feed.Products do
  import Ecto.Query

  alias Feed.Diets.Product

  @repo Feed.Repo
  @dinner_products_table_name "dinner_products"
  @breakfast_products_table_name "breakfast_products"
  @other_products_table_name "other_products"

  def upsert_product(%{"meal" => meal} = attrs) do
    table_name = choose_table_name(meal)

    attrs
    |> get_product(table_name)
    |> put_table(table_name)
    |> Product.changeset(attrs)
    |> @repo.insert_or_update()
  end

  def get_product_by_id(id) do
    @repo.get_by({@breakfast_products_table_name, Product}, id: id)
    ||
    @repo.get_by({@dinner_products_table_name, Product}, id: id)
    ||
    @repo.get_by({@other_products_table_name, Product}, id: id)
  end

  defp get_product(%{"name" => name, "user_id" => user_id}, table_name) do
    @repo.get_by(
      {table_name, Product},
      user_id: user_id,
      name: name
    )
    |> case do
      nil -> %Product{}
      product -> product
    end
  end

  defp choose_table_name(meal) do
    case meal do
      "dinner" -> @dinner_products_table_name
      "breakfast" -> @breakfast_products_table_name
      "other" -> @other_products_table_name
    end
  end

  defp put_table(struct, table_name) do
    put_in(struct.__meta__.source, table_name)
  end

  def get_user_products(user_id, name \\ "") do
    %{
      breakfast: get_user_meal_products(user_id, @breakfast_products_table_name, name),
      dinner: get_user_meal_products(user_id, @dinner_products_table_name, name),
      other: get_user_meal_products(user_id, @other_products_table_name, name)
    }
  end

  defp get_user_meal_products(user_id, table_name, name) do
    name = String.downcase(name)

    query =  (from p in {table_name, Product}) |> where([p], p.user_id == ^user_id)
    query = if name != "", do:  where(query, [p], ilike(p.name, ^"%#{name}%")), else: query
    @repo.all(query)
  end

  def get_user_random_products(number, meal_name, user_id) do
    meal_name
    |> choose_table_name()
    |> get_user_random_products_query(number, user_id)
  end

  defp get_user_random_products_query(table_name, number, user_id) do
    (from product in {table_name, Product}, as: :product)
    |> where([product: product], product.user_id == ^user_id)
    |> @repo.all()
    |> Enum.take_random(number)
  end

  def update_product(product, params) do
    product
    |> Product.update_changeset(params)
    |> @repo.update()
  end

  def delete_product(product), do: @repo.delete(product)
end
