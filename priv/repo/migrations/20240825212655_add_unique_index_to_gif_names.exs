defmodule Gifmaster.Repo.Migrations.AddUniqueIndexToGifNames do
  use Ecto.Migration

  def change do
    # no duplicate gif names allowed
    create(unique_index(:gifs, [:name]))
  end
end
