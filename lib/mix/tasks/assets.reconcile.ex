defmodule Mix.Tasks.Assets.Reconcile do
  @shortdoc "Reconciles legacy S3 assets with local media storage"

  @moduledoc """
  Imports an S3 inventory and archive into local content-addressed storage.

      mix assets.reconcile inventory.json archive-directory mapping.json
  """

  use Mix.Task

  @impl true
  def run([inventory_path, archive_directory | mapping_paths]) do
    Mix.Task.run("app.start")

    inventory = inventory_path |> File.read!() |> Jason.decode!()
    mapping_path = List.first(mapping_paths) || "media-proxy-mapping.json"
    existing_mapping = read_mapping(mapping_path)

    case Gifmaster.Assets.Importer.import(inventory, archive_directory, existing_mapping) do
      {:ok, summary} ->
        write_mapping(mapping_path, inventory, summary)
        Mix.shell().info(Jason.encode!(summary))

      {:error, summary} ->
        write_mapping(mapping_path, inventory, summary)
        Mix.raise("Asset reconciliation failed: #{Jason.encode!(summary)}")
    end
  end

  def run(_arguments), do: Mix.raise("Usage: mix assets.reconcile INVENTORY ARCHIVE_DIRECTORY [MAPPING]")

  defp read_mapping(path) do
    case File.read(path) do
      {:ok, contents} -> Jason.decode!(contents)
      {:error, :enoent} -> %{}
      {:error, reason} -> Mix.raise("Cannot read asset mapping: #{inspect(reason)}")
    end
  end

  defp write_mapping(path, inventory, summary) do
    mapping =
      Map.new(inventory, fn %{"key" => key} ->
        {"/#{key}", mapping_route(key, summary.fallback)}
      end)

    File.write!(path, Jason.encode!(mapping, pretty: true))
  end

  defp mapping_route(key, [key | _fallback_keys]), do: "/__archive/#{key}"
  defp mapping_route(key, [_fallback_key | fallback_keys]), do: mapping_route(key, fallback_keys)
  defp mapping_route(key, []), do: "/#{key}"
end
