defmodule Gifmaster.Catalog.FileTest do
  use ExUnit.Case, async: true

  alias Gifmaster.Catalog.File

  test "loads legacy S3 metadata without Cloudinary fields" do
    changeset =
      File.changeset(%File{}, %{
        bucket: "gems.gifmaster5000.com",
        url: %{relative: "/legacy.gif", absolute: "https://gems.gifmaster5000.com/legacy.gif"}
      })

    assert changeset.valid?
    assert nil == Ecto.Changeset.get_field(changeset, :provider)
    assert nil == Ecto.Changeset.get_field(changeset, :cloudinary_public_id)
  end
end
