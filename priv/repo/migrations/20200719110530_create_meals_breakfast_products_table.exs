defmodule Feed.Repo.Migrations.CreateMealsProductsTables do
  use Ecto.Migration

  def change do
    create table(:meals_breakfast_products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :meal_id, references(:diet_meals, type: :uuid, on_delete: :delete_all)
      add :product_id, references(:breakfast_products, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:meals_breakfast_products, [:meal_id, :product_id], name: :unique_combination_breakfast)

    create table(:meals_dinner_products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :meal_id, references(:diet_meals, type: :uuid, on_delete: :delete_all)
      add :product_id, references(:dinner_products, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:meals_dinner_products, [:meal_id, :product_id], name: :unique_combination_dinner)

    create table(:meals_other_products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :meal_id, references(:diet_meals, type: :uuid, on_delete: :delete_all)
      add :product_id, references(:other_products, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:meals_other_products, [:meal_id, :product_id], name: :unique_combination_other)
  end
end
