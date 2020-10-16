defmodule Feed.Diets.BreakfastIngridient do
  use Feed.Schema

  alias Feed.Diets.Meal

  @required_fields ~w(weight calories carbs fats proteins name)a

  schema "diets_breakfast_ingridients" do
    field :name, :string, null: false
    field :weight, :float, null: false
    field :calories, :float, null: false
    field :carbs, :float, null: false
    field :fats, :float, null: false
    field :proteins, :float, null: false

    belongs_to :meal, Meal

    timestamps()
  end

  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
