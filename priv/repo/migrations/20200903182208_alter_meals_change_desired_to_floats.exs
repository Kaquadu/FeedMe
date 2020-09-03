defmodule Feed.Repo.Migrations.AlterMealsChangeDesiredToFloats do
  use Ecto.Migration

  def change do
    alter table(:diet_meals) do
      modify :desired_calories, :float
      modify :desired_fats, :float
      modify :desired_carbs, :float
      modify :desired_proteins, :float
    end
  end
end
