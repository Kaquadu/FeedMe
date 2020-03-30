defmodule Meet.Auth do
  alias Meet.Auth.User
  alias Meet.AuthEmails

  @repo Meet.Repo

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
end