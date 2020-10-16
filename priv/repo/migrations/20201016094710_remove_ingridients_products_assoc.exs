defmodule Feed.Repo.Migrations.RemoveIngridientsProductsAssoc do
  use Ecto.Migration

  def change do
    alter table(:diets_breakfast_ingridients) do
      remove :product_id

      add :name, :string
      add :calories, :float
      add :fats, :float
      add :proteins, :float
      add :carbs, :float
    end

    alter table(:diets_dinner_ingridients) do
      remove :product_id

      add :name, :string
      add :calories, :float
      add :fats, :float
      add :proteins, :float
      add :carbs, :float
    end

    alter table(:diets_other_ingridients) do
      remove :product_id

      add :name, :string
      add :calories, :float
      add :fats, :float
      add :proteins, :float
      add :carbs, :float
    end
  end
end
