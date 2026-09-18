defmodule Gifmaster.Assets.LocalStorage do
  @moduledoc "Stores immutable content-addressed originals and stable public-name aliases."

  def upload(bytes, options) when is_binary(bytes) do
    filename = Keyword.fetch!(options, :filename)

    with :ok <- validate_filename(filename),
         storage_root = Application.fetch_env!(:gifmaster, :media_storage_root),
         checksum = Base.encode16(:crypto.hash(:sha256, bytes), case: :lower),
         storage_key =
           Path.join(["originals", String.slice(checksum, 0, 2), checksum <> normalized_extension(filename)]),
         original_path = Path.join(storage_root, storage_key),
         alias_path = Path.join([storage_root, "aliases", filename]),
         :ok <- File.mkdir_p(Path.dirname(original_path)),
         :ok <- atomic_write(original_path, bytes),
         :ok <- File.mkdir_p(Path.dirname(alias_path)),
         :ok <- atomic_alias(original_path, alias_path) do
      {:ok,
       %{
         provider: :local,
         storage_key: storage_key,
         checksum: checksum,
         version: checksum,
         format: filename |> normalized_extension() |> String.trim_leading("."),
         byte_count: byte_size(bytes)
       }}
    end
  end

  def verify_delivery(bytes, storage_key) when is_binary(bytes) and is_binary(storage_key) do
    storage_root = Application.fetch_env!(:gifmaster, :media_storage_root)

    with {:ok, stored_bytes} <- File.read(Path.join(storage_root, storage_key)) do
      if :crypto.hash(:sha256, bytes) == :crypto.hash(:sha256, stored_bytes) do
        :ok
      else
        {:error, :delivered_hash_mismatch}
      end
    end
  end

  def verify_checksum(storage_key, checksum) when is_binary(storage_key) and is_binary(checksum) do
    storage_root = Application.fetch_env!(:gifmaster, :media_storage_root)

    with {:ok, stored_bytes} <- File.read(Path.join(storage_root, storage_key)) do
      actual_checksum = Base.encode16(:crypto.hash(:sha256, stored_bytes), case: :lower)

      case actual_checksum do
        ^checksum -> :ok
        _different_checksum -> {:error, :delivered_hash_mismatch}
      end
    end
  end

  def verify(bytes, filename) when is_binary(bytes) and is_binary(filename) do
    storage_root = Application.fetch_env!(:gifmaster, :media_storage_root)
    checksum = Base.encode16(:crypto.hash(:sha256, bytes), case: :lower)
    storage_key = Path.join(["originals", String.slice(checksum, 0, 2), checksum <> normalized_extension(filename)])

    with {:ok, ^bytes} <- File.read(Path.join(storage_root, storage_key)),
         {:ok, ^bytes} <- File.read(Path.join([storage_root, "aliases", filename])) do
      :ok
    else
      {:ok, _different_bytes} -> {:error, :delivered_hash_mismatch}
      {:error, reason} -> {:error, reason}
    end
  end

  defp atomic_write(path, bytes) do
    case File.read(path) do
      {:ok, ^bytes} -> :ok
      {:ok, _different_bytes} -> {:error, :content_address_collision}
      {:error, :enoent} -> write_new_file(path, bytes)
      {:error, reason} -> {:error, reason}
    end
  end

  defp write_new_file(path, bytes) do
    temporary_path = temporary_path(path)

    with :ok <- File.write(temporary_path, bytes, [:binary, :exclusive]),
         :ok <- File.rename(temporary_path, path) do
      :ok
    else
      {:error, reason} ->
        File.rm(temporary_path)
        {:error, reason}
    end
  end

  defp atomic_alias(original_path, alias_path) do
    temporary_path = temporary_path(alias_path)

    with :ok <- File.ln(original_path, temporary_path),
         :ok <- File.rename(temporary_path, alias_path) do
      File.rm(temporary_path)
      :ok
    else
      {:error, reason} ->
        File.rm(temporary_path)
        {:error, reason}
    end
  end

  defp temporary_path(path), do: "#{path}.#{System.unique_integer([:positive])}.tmp"

  defp normalized_extension(filename) do
    filename
    |> Path.extname()
    |> String.downcase()
  end

  defp validate_filename(filename) do
    case {filename, Path.basename(filename)} do
      {invalid, _basename} when invalid in ["", ".", ".."] -> {:error, :invalid_filename}
      {name, name} -> :ok
      {_filename, _basename} -> {:error, :invalid_filename}
    end
  end
end
