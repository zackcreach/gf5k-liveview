defmodule GifmasterWeb.HomeLive do
  @moduledoc """
  Index page with fuzzy search
  """
  use GifmasterWeb, :live_view

  alias Gifmaster.Catalog
  alias Gifmaster.Catalog.Gif
  alias Phoenix.LiveView.AsyncResult

  @public_domain "gems.gifmaster5000.com"

  def mount(_params, _session, socket) do
    socket
    |> assign(
      title: "Gifmaster 5000",
      description: "The best gifs you ever did see",
      show_gif_upload_modal: false,
      uploaded_gifs: [],
      get_gifs_form: to_form(%{"search" => ""}),
      gif_form: to_form(Gif.changeset(%Gif{})),
      gifs: AsyncResult.loading()
    )
    |> assign_async(:gifs, fn -> {:ok, %{gifs: Catalog.get_gifs()}} end)
    |> allow_upload(:gif, accept: [".gif"], max_entries: 1, external: &presign_upload/2)
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <.form for={@get_gifs_form} phx-change="search" phx-submit="search" class="pb-10">
      <.input type="text" name="search" field={@get_gifs_form[:search]} phx-debounce="1000" placeholder="Search..." phx-mounted={JS.focus()} />
    </.form>

    <div class="grid md:grid-cols-6 auto-rows-fr gap-4 text-grey-300">
      <.async_result :let={gifs} assign={@gifs}>
        <:loading>Loading gifs...</:loading>
        <:failed>Error loading gifs</:failed>
        <div :for={gif <- gifs} :if={gifs} class="flex flex-col">
          <img src={gif.file.url.absolute} class="object-cover h-[20vh] min-h-12" />
        </div>
      </.async_result>
    </div>

    <.modal id="gif-upload-modal" show={@show_gif_upload_modal}>
      <h2 class="text-2xl font-semibold mb-4">
        Upload
      </h2>

      <.form for={@gif_form} phx-submit="save_gif" phx-change="validate_gif">
        <div class="w-full aspect-square bg-grey grid place-items-center mb-4">
          <p :if={length(@uploads.gif.entries) == 0}>Preview</p>
          <.live_img_preview :for={entry <- @uploads.gif.entries} :if={@uploads.gif.entries} entry={entry} class="w-full" />
        </div>

        <div class="h-20 border border-dashed border-gold grid place-items-center mb-4" phx-drop-target={@uploads.gif.ref}>
          <.live_file_input class="block w-56" upload={@uploads.gif} required />
        </div>

        <p :for={err <- upload_errors(@uploads.gif)} class="text-red-500 mb-4">
          {error_to_string(err)}
        </p>

        <div class="mb-4">
          <.input label="Name" field={@gif_form[:name]} required />
        </div>

        <div class="relative mb-4">
          <.input type="list" label="Tags" field={@gif_form[:tags]} required />
        </div>

        <.button type="submit">Upload</.button>
      </.form>
    </.modal>
    """
  end

  defp presign_upload(entry, socket) do
    uploads = socket.assigns.uploads
    bucket = @public_domain
    key = entry.client_name

    config = %{
      region: "us-east-1",
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(config, bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads[entry.upload_config].max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{uploader: "S3", key: key, url: "http://#{bucket}.s3.amazonaws.com", fields: fields}
    {:ok, meta, socket}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

  def handle_event("validate_gif", params, socket) do
    gif_form =
      %Gif{}
      |> Gif.changeset(params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, gif_form: gif_form)}
  end

  def handle_event("save_gif", %{"gif" => %{"name" => name}}, socket) do
    filename =
      consume_uploaded_entries(socket, :gif, fn %{key: key}, _entry -> key end)

    socket =
      case Catalog.create_gif(%{
             name: name,
             file: %{url: %{relative: "/#{filename}", absolute: "https://#{@public_domain}/#{filename}"}}
           }) do
        %Gif{} ->
          put_flash(socket, :info, "Gif saved successfully.")

        _error ->
          put_flash(socket, :error, "Error saving gif.")
      end

    {:noreply, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    socket
    |> assign(gifs: AsyncResult.loading())
    |> assign_async(:gifs, fn -> {:ok, %{gifs: Catalog.get_gifs(search)}} end)
    |> noreply()
  end
end
