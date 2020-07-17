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

  def get_user_products(user_id) do
    %{
      breakfast: get_user_meal_products(user_id, @breakfast_products_table_name),
      dinner: get_user_meal_products(user_id, @dinner_products_table_name),
      other: get_user_meal_products(user_id, @other_products_table_name)
    }
  end

  defp get_user_meal_products(user_id, table_name) do
    (from p in {table_name, Product})
    |> where([p], p.user_id == ^user_id)
    |> @repo.all()
  end

  def get_random_products(number, meal_name) do
    meal_name
    |> choose_table_name()
    |> get_random_products_query(number)
  end

  defp get_random_products_query(table_name, number) do
    Ecto.Adapters.SQL.query(@repo,
    """
      SELECT * FROM $1 TABLESAMPLE SYSTEM_ROWS($2);
    """,
    [table_name, number])
  end
end
