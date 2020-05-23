defmodule Feed.Repo.Migrations.MealStatistics do
  use Ecto.Migration

  def change do
    create table(:meal_statistics, primary_key: false) do
      add :id, :uuid, primary_key: false
      add :fit_function_result, :float
      add :coeff_calories, :float
      add :coeff_fats, :float
      add :coeff_carbos, :float
      add :coeff_proteins, :float
      add :meal_id, references(:diet_meals, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
