defmodule Gifmaster.Repo.Migrations.AddGifsTagsTable do
  use Gifmaster.Utils.Migrations

  def change do
    alter table(:gifs) do
      # remove tags array field in favor of many to many relationship
      remove(:tags)
    end

    # no duplicate tags allowed
    create(unique_index(:tags, [:name]))

    create table(:gifs_tags, primary_key: false) do
      add(:gif_id, references(:gifs, type: :text))
      add(:tag_id, references(:tags, type: :text))
    end
  end
end
