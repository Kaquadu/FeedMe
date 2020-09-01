defmodule Feed.Diets.Meal do
  use Feed.Schema

  alias Feed.Auth.User
  alias Feed.Diets.Mealset
  alias Feed.Statistics.MealStatistics

  @required_fields ~w(desired_calories desired_fats desired_carbs desired_proteins mealset_id user_id)a
  @optional_fields ~w(calculated_calories calculated_fats calculated_carbs calculated_proteins)a

  schema "diet_meal" do
    field :desired_calories, :integer, null: false
    field :desired_fats, :integer, null: false
    field :desired_carbs, :integer, null: false
    field :desired_proteins, :integer, null: false
    field :calculated_calories, :float
    field :calculated_fats, :float
    field :calculated_carbs, :float
    field :calculated_proteins, :float

    belongs_to :mealset, Mealset
    belongs_to :user, User

    has_one :meal_statistics, MealStatistics

    many_to_many(
      :breakfast_products,
      {"breakfast_products", Feed.Diets.Product},
      join_through: "meals_breakfast_products",
      on_replace: :delete
    )

    many_to_many(
      :dinner_products,
      {"dinner_products", Feed.Diets.Product},
      join_through: "meals_dinner_products",
      on_replace: :delete
    )

    many_to_many(
      :other_products,
      {"other_products", Feed.Diets.Product},
      join_through: "meals_other_products",
      on_replace: :delete
    )

    timestamps()
  end

  def changeset(meal, attrs \\ %{}) do
    meal
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:meal_statistics, with: &MealStatistics.changeset()/2)
    |> cast_assoc(:breakfast_products)
    |> cast_assoc(:dinner_products)
    |> cast_assoc(:other_products)
    |> validate_required(@required_fields)
  end
end
