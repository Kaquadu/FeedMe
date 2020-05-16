defmodule Feed.ProductSearch do
  use Feed.Schema

  schema "" do
    field :query, :string
  end

  def changeset(search, attrs \\ %{}) do
    cast(search, attrs, [:query])
  end
end
