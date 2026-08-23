defmodule Gifmaster.Assets.Importer do
  @moduledoc """
  Reconciles an exported S3 inventory and local archive with Cloudinary.
  """

  import Ecto.Query

  alias Gifmaster.Assets.Cloudinary
  alias Gifmaster.Catalog.Gif
  alias Gifmaster.Repo

  def import(inventory, archive_directory) when is_list(inventory) do
    inventory
    |> Enum.map(&import_object(&1, archive_directory))
    |> summarize()
  end

  defp import_object(%{"key" => key} = object, archive_directory) do
    path = Path.join(archive_directory, key)

    with {:ok, source_bytes} <- File.read(path),
         :ok <- verify_source(source_bytes, object),
         {:ok, gif} <- matching_gif(key) do
      reconcile_object(source_bytes, key, object, gif)
    else
      {:error, reason} -> {:failed, key, reason}
    end
  end

  defp import_object(object, _archive_directory), do: {:failed, inspect(object), :invalid_inventory_entry}

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

  defp reconcile_object(source_bytes, key, object, gif) do
    if reconciled?(source_bytes, key, object, gif) do
      {:skipped, key}
    else
      upload_object(source_bytes, key, gif)
    end
  end

  defp reconciled?(source_bytes, key, _object, nil) do
    :ok == Cloudinary.verify_delivery(source_bytes, key)
  end

  defp reconciled?(source_bytes, key, object, %Gif{} = gif) do
    verified?(gif, object) and :ok == Cloudinary.verify_delivery(source_bytes, key)
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
    file.provider == :cloudinary and
      is_binary(file.cloudinary_asset_id) and
      verified_byte_count?(file.byte_count, object)
  end

  defp verified_byte_count?(byte_count, %{"byte_count" => expected_count}), do: byte_count == expected_count
  defp verified_byte_count?(_byte_count, _object), do: true

  defp upload(bytes, key) do
    Cloudinary.upload(bytes,
      filename: Path.basename(key),
      content_type: MIME.from_path(key),
      public_id: Path.rootname(key)
    )
  end

  defp verify_delivery(source_bytes, %{delivery_url: delivery_url}) do
    case Req.get(delivery_url, decode_body: false, max_retries: 2) do
      {:ok, %Req.Response{status: 200, body: delivered_bytes}} ->
        if :crypto.hash(:sha256, source_bytes) == :crypto.hash(:sha256, delivered_bytes) do
          :ok
        else
          {:error, :delivered_hash_mismatch}
        end

      {:ok, %Req.Response{status: status}} ->
        {:error, {:delivery_http_error, status}}

      {:error, reason} ->
        {:error, {:delivery_failed, reason}}
    end
  end

  defp verify_delivery(_source_bytes, _metadata), do: {:error, :delivery_url_missing}

  defp update_gif(gif, key, metadata) do
    domain = Application.fetch_env!(:gifmaster, :public_asset_domain)

    file =
      metadata
      |> Map.drop([:delivery_url, :delivery_etag])
      |> Map.put(:url, %{
        relative: "/#{key}",
        absolute: "https://#{domain}/#{key}"
      })

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
      failed: failures
    }

    case failures do
      [] -> {:ok, summary}
      _failures -> {:error, summary}
    end
  end
end
