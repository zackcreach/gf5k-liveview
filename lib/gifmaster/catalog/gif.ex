defmodule Gifmaster.Catalog.Gif do
  use Ecto.Schema
  use Gifmaster.Schema

  import Ecto.Changeset

  schema "gifs" do
    field :name, :string
    field :file, :map
    field :tags, {:array, :string}

    timestamps()
  end

  def changeset(gif, params \\ %{}) do
    gif
    |> cast(params, [:name, :file, :tags])
    |> validate_required([:name, :file, :tags])
  end
end
