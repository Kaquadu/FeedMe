defmodule Feed.Sessions.UserSession do
  use Feed.Schema

  alias Feed.Auth.User

  @required_fields ~w(user_id session_key valid_until)a

  schema "auth_users_sessions" do
    field :session_key, :binary_id
    field :valid_until, :naive_datetime

    belongs_to :user, User

    timestamps()
  end

  def changeset(session, attrs \\ %{}) do
    attrs = prepare_attrs(attrs)

    session
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  defp prepare_attrs(attrs) do
    session_key = Ecto.UUID.generate()
    valid_until = DateTime.utc_now() |> DateTime.add(30 * 60, :second)

    attrs
    |> Map.put(:session_key, session_key)
    |> Map.put(:valid_until, valid_until)
  end
end
