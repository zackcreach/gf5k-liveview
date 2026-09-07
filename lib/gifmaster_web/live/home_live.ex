defmodule GifmasterWeb.HomeLive do
  @moduledoc """
  Index page with fuzzy search
  """
  use GifmasterWeb, :live_view

  alias Ecto.Changeset
  alias Gifmaster.Assets.Cloudinary
  alias Gifmaster.Catalog
  alias Gifmaster.Catalog.Gif
  alias Phoenix.HTML.Form
  alias Phoenix.LiveView.AsyncResult

  @max_upload_size 8_000_000

  def mount(params, _session, socket) do
    socket
    |> assign(
      title: "Gifmaster 5000",
      description: "The best gifs you ever did see",
      get_gifs_form: to_form(%{"search" => ""}),
      gif_form: to_form(get_gif_changeset(params)),
      gifs: AsyncResult.loading()
    )
    |> assign_async(:gifs, fn -> {:ok, %{gifs: Catalog.get_gifs()}} end)
    |> allow_upload(:gif, accept: [".gif"], max_entries: 1, max_file_size: @max_upload_size)
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
          <img src={Cloudinary.preview_url(gif.file)} class="object-cover h-[20vh] min-h-12" loading="lazy" decoding="async" />
        </div>
      </.async_result>
    </div>

    <.modal show={@live_action == :upload} id="gif-upload-modal">
      <h2 class="text-2xl font-semibold mb-4">
        Upload
      </h2>

      <.form for={@gif_form} phx-submit="save_gif" phx-change="validate_gif">
        <div class="w-full aspect-square bg-grey grid place-items-center mb-4">
          <.render_gif {assigns} />
        </div>

        <div class="h-20 border border-dashed border-gold grid place-items-center mb-4" phx-drop-target={@uploads.gif.ref}>
          <.live_file_input class="block w-56" upload={@uploads.gif} required />
        </div>

        <p :for={err <- upload_errors(@uploads.gif)} class="text-red-500 mb-4">
          {error_to_string(err)}
        </p>

        <div class="mb-4">
          <.input label="Name" field={@gif_form[:name]} name="name" required />
        </div>

        <div class="relative mb-4">
          <.input type="list" label="Tags (comma separated)" field={@gif_form[:tags]} name="tags" value={maybe_parse_tags(@gif_form)} required />
        </div>

        <div class="flex gap-x-4">
          <%= if is_binary(Form.input_value(@gif_form, :id)) do %>
            <.button type="submit">Save</.button>
          <% else %>
            <.button type="submit">Upload</.button>
          <% end %>
          <.button :if={Form.input_value(@gif_form, :id)} type="button" phx-click="delete_gif">Delete</.button>
        </div>
      </.form>
    </.modal>
    """
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

  defp maybe_parse_tags(""), do: ""

  defp maybe_parse_tags(form) do
    form
    |> Form.input_value(:tags)
    |> Enum.map_join(",", &Changeset.get_field(&1, :name))
  end

  defp get_gif_changeset(%{"gif_id" => gif_id}) do
    gif_id
    |> Catalog.get_gif()
    |> case do
      %Gif{} = gif -> gif
      nil -> %Gif{}
    end
    |> Gif.changeset()
  end

  defp get_gif_changeset(_params), do: Gif.changeset(%Gif{})

  defp render_gif(%{gif_form: %{data: %{file: %{url: %{absolute: absolute}}}}} = assigns) do
    assigns = assign(assigns, :absolute, absolute)

    ~H"""
    <img class="h-full object-cover" src={@absolute} />
    """
  end

  defp render_gif(%{uploads: %{gif: %{entries: []}}} = assigns), do: ~H"<p>Preview</p>"

  defp render_gif(%{uploads: %{gif: %{entries: entries}}} = assigns) do
    assigns = assign(assigns, :entries, entries)

    ~H"""
    <.live_img_preview :for={entry <- @entries} entry={entry} class="w-full" />
    """
  end

  def handle_event("validate_gif", %{"name" => name} = params, socket) do
    params =
      if length(socket.assigns.uploads.gif.entries) > 0 and name == "" do
        [%Phoenix.LiveView.UploadEntry{client_name: name}] = socket.assigns.uploads.gif.entries
        Map.put(params, "name", Regex.replace(~r/\.\w+$/, name, ""))
      else
        params
      end

    gif_form =
      %Gif{}
      |> Gif.changeset(params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, gif_form: gif_form)}
  end

  def handle_event("save_gif", %{"name" => name, "tags" => tags}, socket) do
    socket =
      case upload_and_create_gif(socket, name, tags) do
        {:ok, %Gif{}} ->
          socket
          |> put_flash(:info, "Gif saved successfully.")
          |> redirect(to: ~p"/")

        {:error, error} ->
          put_flash(socket, :error, "Error saving gif: #{inspect(error)}")
      end

    {:noreply, socket}
  end

  def handle_event("delete_gif", %{"gif_id" => gif_id}, socket) do
    socket =
      case Catalog.delete_gif(gif_id) do
        {:ok, %Gif{}} ->
          socket
          |> put_flash(:info, "Gif deleted successfully")
          |> redirect(to: ~p"/")

        {:error, error} ->
          put_flash(socket, :error, "Error deleting gif: #{error}")
      end

    {:noreply, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    socket
    |> assign(gifs: AsyncResult.loading())
    |> assign_async(:gifs, fn -> {:ok, %{gifs: Catalog.get_gifs(search)}} end)
    |> noreply()
  end

  # edit gif
  def handle_event("open_modal", %{"gif_id" => gif_id}, socket) do
    socket
    |> redirect(to: ~p"/upload/#{gif_id}")
    |> noreply()
  end

  # upload new gif
  def handle_event("open_modal", _params, socket) do
    socket
    |> redirect(to: ~p"/upload/new")
    |> noreply()
  end

  defp upload_and_create_gif(socket, name, tags) do
    case consume_uploaded_entries(socket, :gif, &upload_entry/2) do
      [{:ok, file}] ->
        Catalog.create_gif(%{
          name: name,
          tags: String.split(tags, ","),
          file: file
        })

      [{:error, reason}] ->
        {:error, reason}

      [] ->
        {:error, :gif_required}
    end
  end

  defp upload_entry(%{path: path}, entry) do
    key = normalized_key(entry.client_name)
    public_id = Path.rootname(key)

    with {:ok, bytes} <- File.read(path),
         {:ok, metadata} <-
           Cloudinary.upload(bytes,
             filename: key,
             content_type: entry.client_type,
             public_id: public_id
           ) do
      {:ok, {:ok, Map.merge(metadata, public_urls(key))}}
    else
      {:error, reason} -> {:ok, {:error, reason}}
    end
  end

  defp normalized_key(filename) do
    extension = filename |> Path.extname() |> String.downcase()

    filename
    |> Path.rootname()
    |> Recase.to_snake()
    |> Kernel.<>(extension)
  end

  defp public_urls(key) do
    domain = Application.fetch_env!(:gifmaster, :public_asset_domain)
    %{url: %{relative: "/#{key}", absolute: "https://#{domain}/#{key}"}}
  end
end
