defmodule Feed.Repo.Migrations.CreateIngridients do
  use Ecto.Migration

  def change do
    create table(:diets_breakfast_ingridients, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :weight, :float

      add :meal_id, references(:diet_meals, type: :uuid, on_delete: :delete_all)
      add :product_id, references(:breakfast_products, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create table(:diets_dinner_ingridients, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :weight, :float

      add :meal_id, references(:diet_meals, type: :uuid, on_delete: :delete_all)
      add :product_id, references(:dinner_products, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create table(:diets_other_ingridients, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :weight, :float

      add :meal_id, references(:diet_meals, type: :uuid, on_delete: :delete_all)
      add :product_id, references(:other_products, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
