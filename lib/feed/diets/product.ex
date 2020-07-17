defmodule Feed.Diets.Product do
  use Feed.Schema

  alias Feed.Auth.User
  alias Feed.Diets.Meal

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
    belongs_to :meal, Meal

    timestamps()
  end

  def changeset(product, attrs \\ %{}) do
    product
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:user)
    |> validate_required(@required_fields)
  end
end
