defmodule Feed.Diets.Product do
  use Feed.Schema

  alias Feed.Auth.User

  @required_fields ~w(name carbos fats proteins)a

  schema "abstract table: products" do
    field :name, :string, null: false
    field :carbos, :float, null: false
    field :fats, :float, null: false
    field :proteins, :float, null: false

    belongs_to :user, User

    timestamps()
  end

  def changeset(product, attrs \\ %{}) do
    product
    |> cast(attrs, @required_fields)
    |> cast_assoc(:user)
    |> validate_required(@required_fields)
  end
end
