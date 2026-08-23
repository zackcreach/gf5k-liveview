defmodule GifmasterWeb.Plugs do
  @moduledoc false
  import Phoenix.Controller
  import Plug.Conn

  def init(function), do: function
  def call(conn, function), do: apply(__MODULE__, function, [conn, []])

  def assign_url_helpers(conn, _) do
    assign(conn, :current_url, current_url(conn))
    assign(conn, :current_path, current_path(conn))
  end

  def redirect_legacy_hosts(%Plug.Conn{host: host} = conn, _options)
      when host in ["www.gifmaster5000.com", "gifmaster.prominent.tools"] do
    conn
    |> put_status(:permanent_redirect)
    |> redirect(external: "https://gifmaster5000.com#{conn.request_path}#{query_suffix(conn.query_string)}")
    |> halt()
  end

  def redirect_legacy_hosts(conn, _options), do: conn

  defp query_suffix(""), do: ""
  defp query_suffix(query_string), do: "?#{query_string}"
end
