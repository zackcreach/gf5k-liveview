defmodule Gifmaster.Repo.Migrations.InitialTables do
  use Gifmaster.Utils.Migrations

  def change do
    create table(:gifs) do
      id :gif
      add :name, :string
      add :file, :map 
      add :tags, {:array, :string} 

      timestamps()
    end
  end
end
