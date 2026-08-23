defmodule Gifmaster.Catalog.File do
  @moduledoc false
  use Gifmaster.Schema

  import Ecto.Changeset

  defmodule Url do
    @moduledoc false
    use Gifmaster.Schema

    @primary_key false
    embedded_schema do
      field :relative
      field :absolute
    end
  end

  @primary_key false
  embedded_schema do
    field :bucket, :string
    field :provider, Ecto.Enum, values: [:s3, :cloudinary]
    field :cloudinary_public_id, :string
    field :cloudinary_asset_id, :string
    field :cloudinary_version, :string
    field :format, :string
    field :width, :integer
    field :height, :integer
    field :byte_count, :integer
    embeds_one :url, Url
  end

  def changeset(file, params \\ %{}) do
    file
    |> cast(params, [
      :bucket,
      :provider,
      :cloudinary_public_id,
      :cloudinary_asset_id,
      :cloudinary_version,
      :format,
      :width,
      :height,
      :byte_count
    ])
    |> cast_embed(:url, required: true, with: &url_changeset/2)
  end

  defp url_changeset(url, params) do
    url
    |> cast(params, [:relative, :absolute])
    |> validate_required([:relative, :absolute])
  end
end
