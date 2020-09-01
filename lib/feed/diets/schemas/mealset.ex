defmodule Feed.Diets.Mealset do
  use Feed.Schema

  alias Feed.Auth.User
  alias Feed.Diets.Meal
  alias Feed.Diets.Diet

  @required_fields ~w(diet_id user_id date)a

  schema "diet_mealsets" do
    field :day, :date, null: false

    has_many :meals, Meal
    belongs_to :user, User
    belongs_to :diet, Diet

    timestamps()
  end

  def changeset(product, attrs \\ %{}) do
    product
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
