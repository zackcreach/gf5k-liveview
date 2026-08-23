defmodule Mix.Tasks.Assets.Reconcile do
  @shortdoc "Reconciles legacy S3 assets with Cloudinary"

  @moduledoc """
  Imports an S3 inventory and archive into Cloudinary.

      mix assets.reconcile inventory.json archive-directory mapping.json
  """

  use Mix.Task

  @impl true
  def run([inventory_path, archive_directory | mapping_paths]) do
    Mix.Task.run("app.start")

    inventory = inventory_path |> File.read!() |> Jason.decode!()
    mapping_path = List.first(mapping_paths) || "cloudinary-proxy-mapping.json"

    case Gifmaster.Assets.Importer.import(inventory, archive_directory) do
      {:ok, summary} ->
        write_mapping(mapping_path, inventory)
        Mix.shell().info(Jason.encode!(summary))

      {:error, summary} ->
        write_mapping(mapping_path, inventory)
        Mix.raise("Asset reconciliation failed: #{Jason.encode!(summary)}")
    end
  end

  def run(_arguments), do: Mix.raise("Usage: mix assets.reconcile INVENTORY ARCHIVE_DIRECTORY [MAPPING]")

  defp write_mapping(path, inventory) do
    mapping =
      Map.new(inventory, fn %{"key" => key} ->
        {"/#{key}", "/image/upload/gifmaster/prod/#{Path.rootname(key)}#{Path.extname(key)}"}
      end)

    File.write!(path, Jason.encode!(mapping, pretty: true))
  end
end
