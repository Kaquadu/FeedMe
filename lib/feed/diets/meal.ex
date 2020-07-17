defmodule Feed.Diets.Meal do
  use Feed.Schema

  alias Feed.Auth.User
  alias Feed.Diets.Diet
  alias Feed.Diets.Product
  alias Feed.Statistics.MealStatistics

  @required_fields ~w(desired_calories desired_fats desired_carbs desired_proteins)a
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

    belongs_to :diet, Diet
    belongs_to :user, User

    has_one :meal_statistics, MealStatistics

    has_many :breakfast_products, {"breakfast_products", Product}
    has_many :dinner_products, {"dinner_products", Product}
    has_many :other_products, {"other_products", Product}

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
