defmodule Gifmaster.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  import Ecto.Query

  alias Gifmaster.Assets.Importer
  alias Gifmaster.Assets.LocalStorage
  alias Gifmaster.Catalog.Gif
  alias Gifmaster.Repo

  @app :gifmaster

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def media_inventory do
    start_app()

    summary = %{
      records: Repo.aggregate(Gif, :count),
      local: Repo.aggregate(from(gif in Gif, where: fragment("?->>'provider' = 'local'", gif.file)), :count),
      pending:
        Repo.aggregate(from(gif in Gif, where: fragment("?->>'provider' IS DISTINCT FROM 'local'", gif.file)), :count)
    }

    report(summary)
  end

  def reconcile_media_archive do
    start_app()
    media_directory = System.fetch_env!("GIFMASTER_MEDIA_DIR")
    inventory_path = Path.join(media_directory, "migration/s3-sha256-final.json")
    archive_directory = Path.join(media_directory, "migration/archive")
    inventory = inventory_path |> File.read!() |> Jason.decode!()

    case Importer.import(inventory, archive_directory) do
      {:ok, summary} ->
        report(summary)

      {:error, summary} ->
        raise "Media reconciliation failed: #{Jason.encode!(summary)}"
    end
  end

  def verify_media do
    start_app()

    failures =
      Gif
      |> Repo.all()
      |> Enum.flat_map(&verify_gif/1)

    summary = %{records: Repo.aggregate(Gif, :count), failures: failures}
    report(summary)

    case failures do
      [] -> :ok
      _failures -> raise "Media verification failed: #{Jason.encode!(summary)}"
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp start_app do
    load_app()
    {:ok, _applications} = Application.ensure_all_started(@app)
  end

  defp verify_gif(%Gif{name: name, file: %{provider: :local, storage_key: storage_key, checksum: checksum}})
       when is_binary(storage_key) and is_binary(checksum) do
    case LocalStorage.verify_checksum(storage_key, checksum) do
      :ok -> []
      {:error, reason} -> [%{name: name, reason: inspect(reason)}]
    end
  end

  defp verify_gif(%Gif{name: name}), do: [%{name: name, reason: "not_local"}]

  defp report(summary) do
    IO.puts(Jason.encode!(summary))
    summary
  end

  defp load_app do
    Application.load(@app)
  end
end
