defmodule Feed.Repo.Migrations.CreateDietMealset do
  use Ecto.Migration

  def change do
    create table(:diet_mealsets, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :day, :date

      add :user_id, references(:auth_users, type: :uuid, on_delete: :delete_all)
      add :diet_id, references(:user_diets, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
