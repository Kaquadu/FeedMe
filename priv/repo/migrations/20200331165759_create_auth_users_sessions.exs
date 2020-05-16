defmodule Feed.Repo.Migrations.CreateAuthUsersSessions do
  use Ecto.Migration

  def change do
    create table(:auth_users_sessions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :session_key, :uuid
      add :valid_until, :naive_datetime
      add :user_id, references(:auth_users, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
