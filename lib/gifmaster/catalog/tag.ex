defmodule Gifmaster.Catalog.Tag do
  use Gifmaster.Schema

  import Ecto.Changeset

  schema "tags" do
    field :name, :string

    many_to_many :gifs, Gifmaster.Catalog.Gif, join_through: "gif_tags"

    timestamps()
  end

  def changeset(tag, params \\ %{}) do
    tag
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
