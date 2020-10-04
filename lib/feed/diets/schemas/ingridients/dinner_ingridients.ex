defmodule Feed.Diets.DinnerIngridient do
  use Feed.Schema

  alias Feed.Diets.Product
  alias Feed.Diets.Meal

  @required_fields ~w(weight product_id)a

  schema "diets_dinner_ingridients" do
    field :weight, :float, null: false

    belongs_to :product, {"dinner_products", Product}
    belongs_to :meal, Meal

    timestamps()
  end

  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
