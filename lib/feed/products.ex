defmodule Feed.Products do
  import Ecto.Query
  alias Feed.Diets.Product

  @repo Feed.Repo
  @dinner_products_table_name "dinner_products"
  @breakfast_products_table_name "breakfast_products"
  @other_products_table_name "other_products"

  def create_product(%{"meal" => meal} = attrs) do
    table_name = choose_table_name(meal)

    attrs
    |> get_product(table_name)
    |> put_table(table_name)
    |> Product.changeset(attrs)
    |> @repo.insert_or_update()
  end

  defp get_product(%{"name" => name, "user_id" => user_id}, table_name) do
    query =
      from product in {table_name, Product},
      where: product.user_id == ^user_id,
      where: product.name == ^name

    @repo.all(query) |> hd()
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
end
