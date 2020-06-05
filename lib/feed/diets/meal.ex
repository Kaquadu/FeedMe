defmodule Feed.Diets.Meal do
  use Feed.Schema

  alias Feed.Auth.User
  alias Feed.Diets.Diet
  alias Feed.Statistics.MealStatistics

  @required_fields ~w(desired_calories desired_fats desired_carbos desired_proteins)a
  @optional_fields ~w(calculated_calories calculated_fats calculated_carbos calculated_proteins)a

  schema "diet_meal" do
    field :desired_calories, :integer, null: false
    field :desired_fats, :integer, null: false
    field :desired_carbos, :integer, null: false
    field :desired_proteins, :integer, null: false
    field :calculated_calories, :float
    field :calculated_fats, :float
    field :calculated_carbos, :float
    field :calculated_proteins, :float

    belongs_to :diet, Diet
    belongs_to :user, User

    has_one :meal_statistics, MealStatistics

    timestamps()
  end

  def changeset(meal, attrs \\ %{}) do
    meal
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:diet)
    |> cast_assoc(:user)
    |> validate_required(@required_fields)
  end
end
