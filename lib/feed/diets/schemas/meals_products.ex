defmodule Feed.Diets.MealsProducts do
  use Feed.Schema

  alias Feed.Diets.Product
  alias Feed.Diets.Meal

  @required_fields ~w(product_id meal_id)a
  @optional_fields ~w()a

  schema "abstract table: meals_products" do
    belongs_to :product, Product
    belongs_to :meal, Meal

    timestamps()
  end

  def changeset(meal_product, attrs \\ %{}) do
    meal_product
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
