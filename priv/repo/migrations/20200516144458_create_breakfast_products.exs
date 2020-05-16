defmodule Feed.Repo.Migrations.CreateBreakfastProducts do
  use Ecto.Migration

  def change do
    create table(:breakfast_products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :carbos, :float
      add :fats, :float
      add :proteins, :float

      add :user_id, references(:auth_users, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:breakfast_products, [:name, :user_id])
  end
end
