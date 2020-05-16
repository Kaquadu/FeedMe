defmodule Feed.Auth do
  alias Feed.Auth.User
  alias Feed.AuthEmails

  @repo Feed.Repo

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> @repo.insert()
    |> case do
      {:ok, user} ->
        AuthEmails.send_confirmation_email(user)
        {:ok, user}
      other -> other
    end
  end

  def confirm_email(user_id) do
    @repo.get_by(User, id: user_id) |> maybe_confirm()
  end

  defp maybe_confirm(%User{confirmed_at: nil} = user) do
    user
    |> User.changeset(%{confirmed_at: DateTime.utc_now()})
    |> @repo.update()
  end

  defp maybe_confirm(user), do: {:already_confirmed, user}

  def get_user_by(%{"email" => email}) do
    @repo.get_by(User, email: email)
  end

  def verify_user(%{"email" => email, "password" => password}) do
    user = get_user_by(%{"email" => email})

    {
      Bcrypt.verify_pass(password, user.password_hash),
      user
    }
  end
end
