defmodule Feed.Diets do
  alias Feed.Diets.Diet
  @repo Feed.Repo

  def create_diet(attrs) do
    %Diet{}
    |> Diet.changeset(attrs)
    |> @repo.insert()
  end
end
