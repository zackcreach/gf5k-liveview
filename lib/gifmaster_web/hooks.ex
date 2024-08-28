defmodule GifmasterWeb.Hooks do
  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [attach_hook: 4]

  def on_mount(:global, _params, _session, socket) do
    socket =
      socket
      |> attach_hook(:assign_current_path, :handle_params, &assign_current_path/3)
      |> attach_hook(:assign_current_url, :handle_params, &assign_current_url/3)

    {:cont, socket}
  end

  defp assign_current_path(_params, uri, socket) do
    uri = URI.parse(uri)

    {:cont, assign(socket, :current_path, uri.path)}
  end

  defp assign_current_url(_params, _uri, socket) do
    {:cont, assign(socket, :current_url, Application.get_env(:gifmaster, :base_url))}
  end
end
