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

    timestamps()
  end

  def changeset(meal, attrs \\ %{}) do
    meal
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:meal_statistics, with: &MealStatistics.changeset()/2)
    |> validate_required(@required_fields)
  end
end
