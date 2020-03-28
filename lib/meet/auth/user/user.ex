defmodule Meet.Auth.User do
  use Meet.Schema

  @required_fields ~w(nickname email password password_confirmation)a

  schema "auth_users" do
    field :nickname, :string, null: false
    field :email, :string, null: false
    field :password, :string, virutal: true, null: false
    field :password_confirmation, :string, virutal: true, null: false
    field :password_hash, :string, null: false
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required_fields)
    |> check_confirmation_pwd()
    |> put_password_hash()
  end

  defp check_confirmation_pwd(%Ecto.Changeset{changes:
      %{password: pwd, password_confirmation: pwd_conf}} = changeset) do
    if pwd == pwd_conf do
      changeset
    else
      add_error(changeset, :password_confirmation, "Must be same as password.")
    end
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true,
      changes: %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end
end
