defmodule Feed.Diets.Product do
  use Feed.Schema

  alias Feed.Auth.User

  @required_fields ~w(name carbs fats proteins user_id calories)a
  @optional_fields ~w(photo_url)a

  schema "abstract table: products" do
    field :name, :string, null: false
    field :calories, :float, null: false
    field :carbs, :float, null: false
    field :fats, :float, null: false
    field :proteins, :float, null: false
    field :photo_url, :string

    belongs_to :user, User

    many_to_many(
      :meals,
      Feed.Diets.Meal,
      join_through: "meals_breakfast_products",
      on_replace: :delete
    )

    timestamps()
  end

  def changeset(product, attrs \\ %{}) do
    product
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:meals)
    |> validate_required(@required_fields)
  end

  def changeset_update_product_meals(product, meals) do
    product
    |> cast(%{}, @required_fields ++ @optional_fields)
    |> put_assoc(:meals, meals)
  end
end
