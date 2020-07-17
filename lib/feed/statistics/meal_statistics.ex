defmodule Feed.Statistics.MealStatistics do
  use Feed.Schema

  alias Feed.Diets.Diet

  @required_fields ~w(fit_function_result coeff_calories coeff_fats coeff_carbs coeff_proteins)a

  schema "meal_statistics" do
    field :fit_function_result, :float, null: false
    field :coeff_calories, :float, null: false
    field :coeff_fats, :float, null: false
    field :coeff_carbs, :float, null: false
    field :coeff_proteins, :float, null: false

    belongs_to :meal, Diet

    timestamps()
  end

  def changeset(meal_stats, attrs \\ %{}) do
    meal_stats
    |> cast(attrs, @required_fields)
    |> cast_assoc(:diet)
    |> validate_required(@required_fields)
  end
end
