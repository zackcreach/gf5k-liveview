defmodule Gifmaster.Catalog do
  @moduledoc false
  alias Gifmaster.Catalog.Gif
  alias Gifmaster.Catalog.Repo, as: CatalogRepo
  alias Gifmaster.Repo

  # gifs
  def get_gif(gif_id) do
    CatalogRepo.get_gif(gif_id)
  end

  def get_gifs(search) when search != "" do
    CatalogRepo.get_gifs(search)
  end

  def get_gifs("") do
    CatalogRepo.get_gifs()
  end

  def get_gifs do
    CatalogRepo.get_gifs()
  end

  def create_gif(gif) do
    %Gif{}
    |> Gif.changeset(gif)
    |> Repo.insert!()
  end

  def edit_gif(gif) do
    Gif
    |> Repo.get(gif.id)
    |> Repo.preload(:tags)
    |> Gif.changeset(gif)
    |> Repo.update!()
  end

  def delete_gif(gif_id) do
    CatalogRepo.delete_gif(gif_id)
  end

  # tags
  def get_tags do
    CatalogRepo.get_tags()
  end
end
