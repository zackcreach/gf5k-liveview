defmodule Gifmaster.Catalog.GifsTags do
  use Gifmaster.Schema

  import Ecto.Changeset

  schema "gifstags" do
    belongs_to :gif, Gifmaster.Catalog.Gif
    belongs_to :tag, Gifmaster.Catalog.Tag
  end

  def changeset(gifstags, attrs) do
    gifstags
    |> cast(attrs, [:gif_id, :tag_id])
    |> validate_required([:gif_id, :tag_id])
  end
end
