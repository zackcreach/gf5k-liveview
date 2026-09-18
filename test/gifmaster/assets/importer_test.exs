defmodule Gifmaster.Assets.ImporterTest do
  use Gifmaster.DataCase, async: false

  alias Gifmaster.Assets.Importer
  alias Gifmaster.Catalog.Gif
  alias Gifmaster.Repo

  setup %{tmp_dir: temporary_directory} do
    original_storage_root = Application.get_env(:gifmaster, :media_storage_root)
    storage_root = Path.join(temporary_directory, "storage")
    Application.put_env(:gifmaster, :media_storage_root, storage_root)

    on_exit(fn -> Application.put_env(:gifmaster, :media_storage_root, original_storage_root) end)

    %{storage_root: storage_root}
  end

  @tag :tmp_dir
  test "imports archive objects and updates matching records only after verification", %{
    tmp_dir: temporary_directory,
    storage_root: storage_root
  } do
    bytes = "GIF89a-legacy-asset"
    key = "legacy.gif"
    File.write!(Path.join(temporary_directory, key), bytes)

    gif =
      Repo.insert!(%Gif{
        name: "legacy",
        file: %{
          provider: :cloudinary,
          format: "gif",
          url: %{relative: "/#{key}", absolute: "https://example.test/#{key}"}
        }
      })

    assert {:ok, %{failed: [], fallback: [], imported: 1, skipped: 0}} =
             Importer.import([inventory_entry(key, bytes)], temporary_directory)

    updated_gif = Repo.get!(Gif, gif.id)
    assert :local == updated_gif.file.provider
    assert {:ok, ^bytes} = File.read(Path.join(storage_root, updated_gif.file.storage_key))
    assert {:ok, ^bytes} = File.read(Path.join(storage_root, "aliases/#{key}"))
  end

  @tag :tmp_dir
  test "a repeated import verifies and skips the existing original", %{tmp_dir: temporary_directory} do
    bytes = "GIF89a-repeat"
    key = "repeat.gif"
    File.write!(Path.join(temporary_directory, key), bytes)

    Repo.insert!(%Gif{
      name: "repeat",
      file: %{
        provider: :cloudinary,
        format: "gif",
        url: %{relative: "/#{key}", absolute: "https://example.test/#{key}"}
      }
    })

    inventory = [inventory_entry(key, bytes)]
    assert {:ok, %{imported: 1, skipped: 0}} = Importer.import(inventory, temporary_directory)
    assert {:ok, %{imported: 0, skipped: 1}} = Importer.import(inventory, temporary_directory)
  end

  @tag :tmp_dir
  test "reports every missing and corrupt archive object", %{tmp_dir: temporary_directory} do
    corrupt_key = "corrupt.gif"
    missing_key = "missing.gif"
    File.write!(Path.join(temporary_directory, corrupt_key), "different")

    inventory = [
      %{"key" => corrupt_key, "sha256" => String.duplicate("0", 64)},
      %{"key" => missing_key, "sha256" => String.duplicate("1", 64)}
    ]

    assert {:error, %{failed: failures, imported: 0, skipped: 0}} =
             Importer.import(inventory, temporary_directory)

    assert [corrupt_key, missing_key] == Enum.map(failures, & &1.key)
  end

  @tag :tmp_dir
  test "a repeated archive-only import performs no imports", %{tmp_dir: temporary_directory} do
    bytes = "GIF89a-archive-only"
    key = "archive-only.gif"
    File.write!(Path.join(temporary_directory, key), bytes)
    inventory = [inventory_entry(key, bytes)]

    assert {:ok, %{imported: 1, skipped: 0}} = Importer.import(inventory, temporary_directory)
    assert {:ok, %{imported: 0, skipped: 1}} = Importer.import(inventory, temporary_directory)
  end

  defp inventory_entry(key, bytes) do
    %{
      "key" => key,
      "byte_count" => byte_size(bytes),
      "sha256" => :sha256 |> :crypto.hash(bytes) |> Base.encode16(case: :lower)
    }
  end
end
