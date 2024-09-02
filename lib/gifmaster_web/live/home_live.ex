defmodule GifmasterWeb.HomeLive do
  use GifmasterWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(
      title: "Gifmaster 5000 Catalog",
      description: "The best gifs you ever did see"
    )
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    cool
    """
  end
end
