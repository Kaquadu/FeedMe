defmodule Meet.Auth.User do
  use Meet.Schema

  @casted_fields ~w(nickname email password password_confirmation)a
  @required_fields ~w(nickname email password_hash)a

  schema "auth_users" do
    field :nickname, :string, null: false
    field :email, :string, null: false
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string, null: false
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @casted_fields)
    |> check_confirmation_pwd()
    |> put_password_hash()
    |> validate_required(@required_fields)
  end

  defp check_confirmation_pwd(changeset) do
    (get_field(changeset, :password) == get_field(changeset, :password_confirmation))
    |> if do
      changeset
    else
      add_error(changeset, :password_confirmation, "Must be same as password.")
    end
  end

  defp put_password_hash(changeset) do
    password = get_field(changeset, :password)
    
    change(changeset, Bcrypt.add_hash(password))
  end
end
