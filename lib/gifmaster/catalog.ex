defmodule Gifmaster.Catalog do
  alias Gifmaster.Repo
  alias Gifmaster.Catalog.Repo, as: CatalogRepo

  # gifs
  def get_gif(id) do
    CatalogRepo.get_gif(id)
  end

  def get_gifs() do
    CatalogRepo.get_gifs()
  end

  def create_gif(gif) do
    Repo.insert(gif)
  end

  def edit_gif(gif) do
    Repo.update(gif)
  end

  def delete_gif(id) do
    CatalogRepo.delete_gif(id)
  end
end
