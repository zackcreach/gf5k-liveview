defmodule Gifmaster.Catalog.Repo do
  import Ecto.Query

  alias Gifmaster.Catalog.{Gif, Tag}
  alias Gifmaster.Repo

  # gifs
  def get_gif(id) do
    Gif
    |> Repo.get(id)
    |> Repo.preload(:tags)
  end

  def get_gifs(search) do
    query =
      from(g in Gif,
        join: t in assoc(g, :tags),
        preload: [tags: t],
        order_by: [asc: g.id],
        where:
          fragment("to_tsvector('english', ? || ' ' || ?) @@ to_tsquery(?)", g.name, t.name, ^prefix_search(search))
      )

    Repo.all(query)
  end

  def get_gifs() do
    query = from(g in Gif, order_by: [asc: g.id])

    Repo.all(query)
  end

  defp prefix_search(term), do: String.replace(term, ~r/\W/u, "") <> ":*"

  def delete_gif(id) do
    gif = get_gif(id)

    Repo.delete(gif)
  end

  # tags
  def get_tags() do
    query = from(t in Tag, order_by: [asc: t.id])

    Repo.all(query)
  end
end
