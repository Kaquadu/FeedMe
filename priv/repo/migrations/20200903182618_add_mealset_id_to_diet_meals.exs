defmodule Feed.Repo.Migrations.AddMealsetIdToDietMeals do
  use Ecto.Migration

  def change do
    alter table(:diet_meals) do
      add :mealset_id, references(:diet_mealsets, type: :uuid, on_delete: :delete_all)
    end
  end
end
