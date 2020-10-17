defmodule Feed.Diets.Meal do
  use Feed.Schema

  alias Feed.Auth.User
  alias Feed.Diets.Mealset
  alias Feed.Diets.BreakfastIngridient
  alias Feed.Diets.DinnerIngridient
  alias Feed.Diets.OtherIngridient
  alias Feed.Statistics.MealStatistics

  @required_fields ~w(desired_calories desired_fats desired_carbs desired_proteins mealset_id user_id)a
  @optional_fields ~w(calculated_calories calculated_fats calculated_carbs calculated_proteins)a

  schema "diet_meals" do
    field :desired_calories, :float, null: false
    field :desired_fats, :float, null: false
    field :desired_carbs, :float, null: false
    field :desired_proteins, :float, null: false
    field :calculated_calories, :float
    field :calculated_fats, :float
    field :calculated_carbs, :float
    field :calculated_proteins, :float

    belongs_to :mealset, Mealset
    belongs_to :user, User

    has_one :meal_statistics, MealStatistics

    has_many :breakfast_ingridients, BreakfastIngridient
    has_many :dinner_ingridients, DinnerIngridient
    has_many :other_ingridients, OtherIngridient

    timestamps()
  end

  def changeset(meal, attrs \\ %{}) do
    meal
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:meal_statistics, with: &MealStatistics.changeset()/2)
    |> cast_assoc(:breakfast_ingridients, with: &BreakfastIngridient.changeset()/2)
    |> cast_assoc(:dinner_ingridients, with: &DinnerIngridient.changeset()/2)
    |> cast_assoc(:other_ingridients, with: &OtherIngridient.changeset()/2)
    |> validate_required(@required_fields)
  end
end
