defmodule Feed.Diets.Diet do
  use Feed.Schema

  alias Feed.Auth.User
  alias Feed.Diets.Mealset

  @required_fields ~w(name calories carbs fats proteins no_big_meals no_small_meals user_id)a

  schema "user_diets" do
    field :name, :string, null: false
    field :calories, :integer, null: false
    field :no_big_meals, :integer, null: false
    field :no_small_meals, :integer, null: false
    field :carbs, :integer, null: false
    field :fats, :integer, null: false
    field :proteins, :integer, null: false

    belongs_to :user, User
    has_many :mealsets, Mealset

    timestamps()
  end

  def changeset(diet, attrs \\ %{}) do
    diet
    |> cast(attrs, @required_fields)
    |> cast_assoc(:mealsets)
    |> validate_required(@required_fields)
  end
end
