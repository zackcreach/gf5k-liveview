defmodule Gifmaster.Catalog do
  alias Gifmaster.Repo
  alias Gifmaster.Catalog.Gif
  alias Gifmaster.Catalog.Repo, as: CatalogRepo

  # gifs
  def get_gif(id) do
    CatalogRepo.get_gif(id)
  end

  def get_gifs(search) do
    CatalogRepo.get_gifs(search)
  end

  def get_gifs() do
    CatalogRepo.get_gifs()
  end

  def create_gif(gif) do
    %Gif{}
    |> Gif.changeset(gif)
    |> Repo.insert!()
  end

  def edit_gif(gif) do
    Repo.get(Gif, gif.id)
    |> Repo.preload(:tags)
    |> Gif.changeset(gif)
    |> Repo.update!()
  end

  def delete_gif(id) do
    CatalogRepo.delete_gif(id)
  end

  # tags
  def get_tags() do
    CatalogRepo.get_tags()
  end
end
