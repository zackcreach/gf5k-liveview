defmodule Gifmaster.Assets.Importer do
  @moduledoc """
  Reconciles an exported S3 inventory and local archive with local storage.
  """

  import Ecto.Query

  alias Gifmaster.Assets.LocalStorage
  alias Gifmaster.Catalog.Gif
  alias Gifmaster.Repo

  def import(inventory, archive_directory, mapping \\ %{}) when is_list(inventory) and is_map(mapping) do
    inventory
    |> Enum.map(&import_object(&1, archive_directory, mapping))
    |> summarize()
  end

  defp import_object(%{"key" => key} = object, archive_directory, mapping) do
    path = Path.join(archive_directory, key)

    with {:ok, source_bytes} <- File.read(path),
         :ok <- verify_source(source_bytes, object) do
      reconcile_object(source_bytes, key, object, mapping)
    else
      {:error, reason} -> {:failed, key, reason}
    end
  end

  defp import_object(object, _archive_directory, _mapping), do: {:failed, inspect(object), :invalid_inventory_entry}

  defp verify_source(bytes, %{"sha256" => expected_hash}) do
    actual_hash = :sha256 |> :crypto.hash(bytes) |> Base.encode16(case: :lower)

    if actual_hash == String.downcase(expected_hash) do
      :ok
    else
      {:error, {:source_hash_mismatch, expected_hash, actual_hash}}
    end
  end

  defp verify_source(bytes, %{"byte_count" => expected_count}) when byte_size(bytes) == expected_count, do: :ok
  defp verify_source(_bytes, %{"byte_count" => expected_count}), do: {:error, {:source_size_mismatch, expected_count}}
  defp verify_source(_bytes, _object), do: :ok

  defp matching_gif(key) do
    relative_url = "/#{key}"

    Gif
    |> where([gif], fragment("?->'url'->>'relative' = ?", gif.file, ^relative_url))
    |> Repo.one()
    |> case do
      %Gif{} = gif -> {:ok, gif}
      nil -> {:ok, nil}
    end
  end

  defp reconcile_object(source_bytes, key, object, _mapping) do
    with {:ok, gif} <- matching_gif(key) do
      source_bytes
      |> reconciled?(key, object, gif)
      |> reconcile_local(source_bytes, key, gif)
    end
  end

  defp reconcile_local(true, _source_bytes, key, _gif), do: {:skipped, key}
  defp reconcile_local(false, source_bytes, key, gif), do: upload_object(source_bytes, key, gif)

  defp reconciled?(source_bytes, key, _object, nil), do: :ok == LocalStorage.verify(source_bytes, Path.basename(key))

  defp reconciled?(source_bytes, _key, object, %Gif{} = gif) do
    verified?(gif, object) and :ok == LocalStorage.verify_delivery(source_bytes, gif.file.storage_key)
  end

  defp upload_object(source_bytes, key, gif) do
    with {:ok, metadata} <- upload(source_bytes, key),
         :ok <- verify_delivery(source_bytes, metadata),
         {:ok, persisted_asset} <- persist_asset(gif, key, metadata) do
      {:imported, key, persisted_asset}
    else
      {:error, reason} -> {:failed, key, reason}
    end
  end

  defp verified?(%Gif{file: file}, object) do
    file.provider == :local and
      is_binary(file.storage_key) and
      is_binary(file.checksum) and
      verified_byte_count?(file.byte_count, object)
  end

  defp verified_byte_count?(byte_count, %{"byte_count" => expected_count}), do: byte_count == expected_count
  defp verified_byte_count?(_byte_count, _object), do: true

  defp upload(bytes, key) do
    LocalStorage.upload(bytes,
      filename: Path.basename(key),
      content_type: MIME.from_path(key),
      public_id: Path.rootname(key)
    )
  end

  defp verify_delivery(source_bytes, %{storage_key: storage_key}),
    do: LocalStorage.verify_delivery(source_bytes, storage_key)

  defp verify_delivery(_source_bytes, _metadata), do: {:error, :storage_key_missing}

  defp update_gif(gif, key, metadata) do
    domain = Application.fetch_env!(:gifmaster, :public_asset_domain)

    file =
      gif.file
      |> Map.from_struct()
      |> Map.merge(metadata)
      |> Map.put(:url, %{relative: "/#{key}", absolute: "https://#{domain}/#{key}"})

    gif
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_embed(:file, file)
    |> Repo.update()
  end

  defp persist_asset(nil, _key, metadata), do: {:ok, metadata}

  defp persist_asset(%Gif{} = gif, key, metadata) do
    case update_gif(gif, key, metadata) do
      {:ok, updated_gif} -> {:ok, updated_gif.file}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp summarize(results) do
    failures = Enum.filter(results, &match?({:failed, _key, _reason}, &1))

    summary = %{
      imported: Enum.count(results, &match?({:imported, _key, _file}, &1)),
      skipped: Enum.count(results, &match?({:skipped, _key}, &1)),
      fallback: [],
      failed:
        Enum.map(failures, fn {:failed, key, reason} ->
          %{key: key, reason: inspect(reason, limit: :infinity)}
        end)
    }

    case failures do
      [] -> {:ok, summary}
      _failures -> {:error, summary}
    end
  end
end
