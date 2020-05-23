defmodule Feed.Repo.Migrations.CreateUserDiets do
  use Ecto.Migration

  def change do
    create table(:user_diets, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :no_big_meals, :integer
      add :no_small_meals, :integer
      add :calories, :integer
      add :carbos, :integer
      add :fats, :integer
      add :proteins, :integer

      add :user_id, references(:auth_users, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
