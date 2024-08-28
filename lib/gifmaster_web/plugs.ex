defmodule GifmasterWeb.Plugs do
  import Plug.Conn
  import Phoenix.Controller

  def assign_url_helpers(conn, _) do
    assign(conn, :current_url, current_url(conn))
    assign(conn, :current_path, current_path(conn))
  end
end
