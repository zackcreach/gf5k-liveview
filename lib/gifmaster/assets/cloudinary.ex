defmodule Gifmaster.Assets.Cloudinary do
  @moduledoc """
  Uploads Gifmaster assets without exposing Cloudinary credentials to clients.
  """

  @default_endpoint "https://api.cloudinary.com/v1_1"

  def upload(bytes, options) when is_binary(bytes) do
    with {:ok, config} <- config(),
         {:ok, public_id} <- fetch_option(options, :public_id),
         {:ok, filename} <- fetch_option(options, :filename) do
      fields = [
        file: {bytes, filename: filename, content_type: Keyword.get(options, :content_type)},
        public_id: public_id,
        overwrite: "true",
        invalidate: "true",
        resource_type: "image"
      ]

      fields = maybe_add_folder(fields, config.folder)

      "#{config.endpoint}/#{config.cloud_name}/image/upload"
      |> Req.post(
        [
          auth: {:basic, "#{config.api_key}:#{config.api_secret}"},
          form_multipart: fields,
          decode_body: :json,
          max_retries: 2
        ] ++ config.request_options
      )
      |> normalize_response()
    end
  end

  defp config do
    config = Application.get_env(:gifmaster, __MODULE__, [])

    with {:ok, cloud_name} <- fetch_config(config, :cloud_name),
         {:ok, api_key} <- fetch_config(config, :api_key),
         {:ok, api_secret} <- fetch_config(config, :api_secret) do
      {:ok,
       %{
         cloud_name: cloud_name,
         api_key: api_key,
         api_secret: api_secret,
         folder: Keyword.get(config, :folder),
         endpoint: Keyword.get(config, :endpoint, @default_endpoint),
         request_options: Keyword.get(config, :request_options, [])
       }}
    end
  end

  defp fetch_config(config, key) do
    case Keyword.get(config, key) do
      value when is_binary(value) and value != "" -> {:ok, value}
      _missing -> {:error, {:missing_config, key}}
    end
  end

  defp fetch_option(options, key) do
    case Keyword.get(options, key) do
      value when is_binary(value) and value != "" -> {:ok, value}
      _missing -> {:error, {:missing_option, key}}
    end
  end

  defp maybe_add_folder(fields, folder) when is_binary(folder) and folder != "",
    do: Keyword.put(fields, :folder, folder)

  defp maybe_add_folder(fields, _folder), do: fields

  defp normalize_response({:ok, %Req.Response{status: status, body: body}}) when status in 200..299 do
    body = decode_body(body)

    {:ok,
     %{
       provider: :cloudinary,
       cloudinary_public_id: body["public_id"],
       cloudinary_asset_id: body["asset_id"],
       cloudinary_version: version_to_string(body["version"]),
       delivery_url: body["secure_url"],
       delivery_etag: body["etag"],
       format: body["format"],
       width: body["width"],
       height: body["height"],
       byte_count: body["bytes"]
     }}
  end

  defp normalize_response({:ok, %Req.Response{status: status, body: body}}),
    do: {:error, {:http_error, status, decode_body(body)}}

  defp normalize_response({:error, reason}), do: {:error, reason}

  defp decode_body(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> decoded
      {:error, _reason} -> body
    end
  end

  defp decode_body(body), do: body
  defp version_to_string(nil), do: nil
  defp version_to_string(version), do: to_string(version)
end
