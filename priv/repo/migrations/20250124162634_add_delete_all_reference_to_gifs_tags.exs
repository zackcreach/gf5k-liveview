defmodule Gifmaster.Repo.Migrations.AddDeleteAllReferenceToGifsTags do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:gifs_tags) do
      modify(:gif_id, references(:gifs, on_delete: :delete_all, type: :text), from: references(:gifs, type: :text))
    end
  end
end
