defmodule Feed.Diets.Product do
  use Feed.Schema

  alias Feed.Auth.User

  @required_fields ~w(name carbs fats proteins user_id calories)a
  @optional_fields ~w(photo_url min_weight max_weight)a
  @user_update_fields ~w(min_weight max_weight)a

  schema "abstract table: products" do
    field :name, :string, null: false
    field :calories, :float, null: false
    field :carbs, :float, null: false
    field :fats, :float, null: false
    field :proteins, :float, null: false
    field :min_weight, :float, null: false, default: 0.25
    field :max_weight, :float, null: false, default: 3.5
    field :photo_url, :string

    belongs_to :user, User

    timestamps()
  end

  def changeset(product, attrs \\ %{}) do
    product
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_number(:min_weight, greater_than: 0.0, less_than: 5)
    |> validate_number(:max_weight, greater_than: 0.0, less_than: 5)
    |> validate_weitghts_ratio()
    |> validate_required(@required_fields)
  end

  def update_changeset(product, attrs \\ %{}) do
    product
    |> cast(attrs, @user_update_fields)
    |> validate_number(:min_weight, greater_than: 0.0, less_than: 5)
    |> validate_number(:max_weight, greater_than: 0.0, less_than: 5)
    |> validate_weitghts_ratio()
  end

  defp validate_weitghts_ratio(%{changes: %{min_weight: min, max_weight: max}} = changeset) do
    if (max / min) > 1.0, do: changeset, else: add_error(changeset, :max_weight, "Must be greater than min weight")
  end

  defp validate_weitghts_ratio(changeset), do: changeset
end
