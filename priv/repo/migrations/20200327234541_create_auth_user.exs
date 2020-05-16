defmodule Feed.Repo.Migrations.CreateAuthUsers do
  use Ecto.Migration

  def change do
    create table(:auth_users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :nickname, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :confirmed_at, :naive_datetime

      timestamps()
    end

    create unique_index(:auth_users, :nickname)
    create unique_index(:auth_users, :email)
  end
end
