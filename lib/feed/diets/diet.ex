defmodule Feed.Diets.Diet do
  use Feed.Schema

  alias Feed.Auth.User

  @required_fields ~w(name calories carbos fats proteins no_meals user_id)a

  schema "user_diets" do
    field :name, :string, null: false
    field :calories, :integer, null: false
    field :no_meals, :integer, null: false
    field :carbos, :integer, null: false
    field :fats, :integer, null: false
    field :proteins, :integer, null: false

    belongs_to :user, User

    timestamps()
  end

  def changeset(diet, attrs \\ %{}) do
    diet
    |> cast(attrs, @required_fields)
    |> cast_assoc(:user)
    |> validate_required(@required_fields)
  end
end
