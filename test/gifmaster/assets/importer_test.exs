defmodule Gifmaster.Assets.ImporterTest do
  use ExUnit.Case, async: true

  alias Gifmaster.Assets.Importer

  @tag :tmp_dir
  test "accepts an exact configured archive fallback without contacting Cloudinary", %{tmp_dir: temporary_directory} do
    bytes = "legacy-asset"
    key = "legacy.gif"
    File.write!(Path.join(temporary_directory, key), bytes)

    inventory = [
      %{
        "key" => key,
        "byte_count" => byte_size(bytes),
        "sha256" => :sha256 |> :crypto.hash(bytes) |> Base.encode16(case: :lower)
      }
    ]

    assert {:ok, %{failed: [], fallback: [^key], imported: 0, skipped: 0}} =
             Importer.import(inventory, temporary_directory, %{"/#{key}" => "/__archive/#{key}"})
  end

  @tag :tmp_dir
  test "rejects a configured fallback when the archived bytes do not match", %{tmp_dir: temporary_directory} do
    key = "legacy.gif"
    File.write!(Path.join(temporary_directory, key), "different")

    inventory = [%{"key" => key, "sha256" => String.duplicate("0", 64)}]

    assert {:error,
            %{
              fallback: [],
              imported: 0,
              skipped: 0,
              failed: [%{key: ^key, reason: reason}]
            }} = Importer.import(inventory, temporary_directory, %{"/#{key}" => "/__archive/#{key}"})

    assert reason =~ "source_hash_mismatch"
  end
end
