defmodule Feed.Schema do
  defmacro __using__(_opts) do
    quote do
      # uses
      use Ecto.Schema

      # imports
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      # requires
      require IEx

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      @type t :: %__MODULE__{}
    end
  end
end
