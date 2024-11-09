defmodule GifmasterWeb.HomeLive do
  @moduledoc """
  Index page with fuzzy search
  """
  use GifmasterWeb, :live_view

  alias Gifmaster.Catalog
  alias Phoenix.LiveView.AsyncResult

  def mount(_params, _session, socket) do
    socket
    |> assign(
      title: "Gifmaster 5000 Catalog",
      description: "The best gifs you ever did see",
      form: to_form(%{"search" => ""}),
      gifs: AsyncResult.loading()
    )
    |> assign_async(:gifs, fn -> {:ok, %{gifs: Catalog.get_gifs()}} end)
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="search" phx-submit="search" class="pb-10">
      <.input type="text" name="search" field={@form[:search]} phx-debounce="1000" placeholder="Search..." phx-mounted={JS.focus()} />
    </.form>

    <div class="grid grid-cols-6 auto-rows-fr gap-4">
      <.async_result :let={gifs} assign={@gifs}>
        <:loading>Loading gifs...</:loading>
        <:failed>Error loading gifs</:failed>
        <div :for={gif <- gifs} :if={gifs} class="flex flex-col">
          <img src={gif.file.url.absolute} class="object-cover h-[20vh] min-h-12" />
        </div>
      </.async_result>
    </div>
    """
  end

  def handle_event("search", %{"search" => search}, socket) do
    socket
    |> assign(gifs: AsyncResult.loading())
    |> assign_async(:gifs, fn -> {:ok, %{gifs: Catalog.get_gifs(search)}} end)
    |> noreply()
  end
end
