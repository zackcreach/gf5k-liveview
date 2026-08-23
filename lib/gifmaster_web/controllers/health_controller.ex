defmodule GifmasterWeb.HealthController do
  use GifmasterWeb, :controller

  def show(conn, _params) do
    case Ecto.Adapters.SQL.query(Gifmaster.Repo, "SELECT 1", []) do
      {:ok, _result} -> json(conn, %{status: "ok"})
      {:error, _reason} -> conn |> put_status(:service_unavailable) |> json(%{status: "unavailable"})
    end
  end
end
