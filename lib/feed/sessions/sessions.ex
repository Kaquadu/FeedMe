defmodule Feed.Sessions do
  alias Feed.Auth
  alias Feed.Sessions.UserSession

  @repo Feed.Repo

  def sign_in_user(attrs) do
    attrs
    |> Auth.verify_user()
    |> case do
      {true, user} ->
        create_user_session(user)
      {false, _} ->
        {:error, "Incorrect password email or password"}
      end
  end

  def create_user_session(user) do
    %UserSession{}
    |> UserSession.changeset(%{user_id: user.id})
    |> @repo.insert()
  end

  def terminate_user_session(id) do
    UserSession
    |> @repo.get(id)
    |> UserSession.changeset(%{valid_until: DateTime.utc_now()})
    |> @repo.update()
  end
end
