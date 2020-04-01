defmodule Meet.Sessions do
  alias Meet.Auth
  alias Meet.Sessions.UserSession

  @repo Meet.Repo

  def sign_in_user(attrs) do
    attrs
    |> Auth.verify_user()
    |> case do
      {true, user} ->
        create_session(user)
      {false, _} ->
        {:error, "Incorrect password email or password"}
      end
  end

  def create_session(user) do
    %UserSession{}
    |> UserSession.changeset(%{user_id: user.id})
    |> @repo.insert()
  end

  def terminate_session(id) do
    UserSession
    |> @repo.get(id)
    |> UserSession.changeset(%{valid_until: DateTime.utc_now()})
    |> @repo.update()
  end
end
