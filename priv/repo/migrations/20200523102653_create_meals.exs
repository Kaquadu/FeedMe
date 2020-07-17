defmodule Feed.Repo.Migrations.CreateMeals do
  use Ecto.Migration

  def change do
    create table(:diet_meals, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :desired_calories, :integer
      add :desired_fats, :integer
      add :desired_carbs, :integer
      add :desired_proteins, :integer
      add :calculated_calories, :float
      add :calculated_fats, :float
      add :calculated_carbs, :float
      add :calculated_proteins, :float

      add :diet_id, references(:user_diets, type: :uuid, on_delete: :delete_all)
      add :user_id, references(:auth_users, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
