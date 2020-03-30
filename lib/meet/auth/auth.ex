defmodule Meet.Auth do
  alias Meet.Auth.User

  @repo Meet.Repo

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> @repo.insert()
  end
end
