defmodule Gifmaster.Assets.LocalStorageTest do
  use ExUnit.Case, async: false

  alias Gifmaster.Assets.LocalStorage

  setup do
    storage_root = Path.join(System.tmp_dir!(), "gifmaster-storage-#{System.unique_integer([:positive])}")
    original_storage_root = Application.get_env(:gifmaster, :media_storage_root)
    Application.put_env(:gifmaster, :media_storage_root, storage_root)

    on_exit(fn ->
      File.rm_rf!(storage_root)
      Application.put_env(:gifmaster, :media_storage_root, original_storage_root)
    end)

    :ok
  end

  test "stores an immutable original and updates the stable alias" do
    assert {:ok, first} = LocalStorage.upload("first", filename: "example.gif")
    assert {:ok, second} = LocalStorage.upload("second", filename: "example.gif")

    refute first.storage_key == second.storage_key
    assert first.checksum == first.version
    assert :ok == LocalStorage.verify_delivery("first", first.storage_key)

    assert {:ok, "second"} =
             File.read(Path.join(Application.fetch_env!(:gifmaster, :media_storage_root), "aliases/example.gif"))
  end

  test "rejects alias traversal" do
    assert {:error, :invalid_filename} == LocalStorage.upload("bytes", filename: "../example.gif")
  end

  test "rejects different bytes at an existing content-addressed path" do
    assert {:ok, metadata} = LocalStorage.upload("first", filename: "example.gif")
    path = Path.join(Application.fetch_env!(:gifmaster, :media_storage_root), metadata.storage_key)
    File.write!(path, "corrupt")

    assert {:error, :content_address_collision} == LocalStorage.upload("first", filename: "example.gif")
  end
end
