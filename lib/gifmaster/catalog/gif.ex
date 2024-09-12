defmodule Gifmaster.Catalog.Gif do
  use Gifmaster.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Gifmaster.Repo
  alias Gifmaster.Catalog.File
  alias Gifmaster.Catalog.Tag

  schema "gifs" do
    field :name, :string
    embeds_one :file, File, on_replace: :delete

    many_to_many :tags, Tag, join_through: "gifs_tags", on_replace: :delete

    timestamps()
  end

  def changeset(gif, params \\ %{}) do
    gif
    |> cast(params, [:name])
    |> cast_embed(:file)
    |> validate_required([:name, :file])
    |> put_assoc(:tags, parse_tags(params))
  end

  defp parse_tags(params) do
    (params[:tags] || [])
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> insert_and_get_all()
  end

  defp insert_and_get_all([]), do: []

  defp insert_and_get_all(names) do
    timestamp = DateTime.utc_now()
    placeholders = %{timestamp: timestamp}

    maps =
      Enum.map(
        names,
        &%{
          name: &1,
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      )

    Repo.insert_all(Tag, maps, placeholders: placeholders, on_conflict: :nothing)

    query = from(t in Tag, where: t.name in ^names)
    Repo.all(query)
  end
end
