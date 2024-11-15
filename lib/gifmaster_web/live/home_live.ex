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
      show_gif_upload_modal: true,
      get_gifs_form: to_form(%{"search" => ""}),
      # Switch out to_form to Catalog.create_gif()
      upload_gif_form:
        to_form(%{
          "name" => "",
          "tags" => [],
          "file" => %{"url" => %{"relative" => "", "absolute" => ""}}
        }),
      gifs: AsyncResult.loading()
    )
    |> assign_async(:gifs, fn -> {:ok, %{gifs: Catalog.get_gifs()}} end)
    |> allow_upload(:gif, accept: [".gif"], max_entries: 1)
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <.form for={@get_gifs_form} phx-change="search" phx-submit="search" class="pb-10">
      <.input type="text" name="search" field={@get_gifs_form[:search]} phx-debounce="1000" placeholder="Search..." phx-mounted={JS.focus()} />
    </.form>

    <div class="grid grid-cols-6 auto-rows-fr gap-4 text-grey-300">
      <.async_result :let={gifs} assign={@gifs}>
        <:loading>Loading gifs...</:loading>
        <:failed>Error loading gifs</:failed>
        <div :for={gif <- gifs} :if={gifs} class="flex flex-col">
          <img src={gif.file.url.absolute} class="object-cover h-[20vh] min-h-12" />
        </div>
      </.async_result>
    </div>

    <.modal id="gif-upload-modal" show={@show_gif_upload_modal}>
      <h2 class="text-2xl font-semibold">
        Upload Gif
      </h2>

      <.form for={@upload_gif_form}></.form>
    </.modal>
    """
  end

  def handle_event("search", %{"search" => search}, socket) do
    socket
    |> assign(gifs: AsyncResult.loading())
    |> assign_async(:gifs, fn -> {:ok, %{gifs: Catalog.get_gifs(search)}} end)
    |> noreply()
  end
end
