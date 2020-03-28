defmodule Meet.Repo.Migrations.CreateAuthUsers do
  use Ecto.Migration

  def change do
    create table(:auth_users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :nickname, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
    end
  end
end
