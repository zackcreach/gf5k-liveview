defmodule Gifmaster.Catalog.Repo do
  import Ecto.Query

  alias Gifmaster.Catalog.Gif
  alias Gifmaster.Repo

  # gifs
  def get_gif(id) do
    Repo.get(Gif, id)
  end

  def get_gifs() do
    query =
      from(g in Gif, order_by: [asc: g.id])

    Repo.all(query)
  end

  def delete_gif(id) do
    gif = get_gif(id)
    Repo.delete(gif)
  end
end
