defmodule Feed.Repo.Migrations.AddMinMaxWeigthsToProducts do
  use Ecto.Migration

  def change do
    alter table(:breakfast_products) do
      add :min_weight, :float, default: 0.5
      add :max_weight, :float, default: 3.5
    end

    alter table(:dinner_products) do
      add :min_weight, :float, default: 0.5
      add :max_weight, :float, default: 3.5
    end

    alter table(:other_products) do
      add :min_weight, :float, default: 0.5
      add :max_weight, :float, default: 3.5
    end
  end
end
