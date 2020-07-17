defmodule Feed.Repo.Migrations.CreateDinnerProducts do
  use Ecto.Migration

  def change do
    create table(:dinner_products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :carbs, :float
      add :fats, :float
      add :proteins, :float
      add :calories, :float
      add :photo_url, :string

      add :user_id, references(:auth_users, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:dinner_products, [:name, :user_id])
  end
end
