defmodule Gifmaster.Catalog.File do
  use Gifmaster.Schema

  import Ecto.Changeset

  defmodule Url do
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
    embeds_one :url, Url
  end

  def changeset(file, params \\ %{}) do
    file
    |> change(bucket: Application.get_env(:gifmaster, :aws_bucket))
    |> cast(params, [:bucket])
    |> cast_embed(:url, required: true, with: &url_changeset/2)
  end

  defp url_changeset(url, params) do
    url
    |> cast(params, [:relative, :absolute])
    |> validate_required([:relative, :absolute])
  end
end
