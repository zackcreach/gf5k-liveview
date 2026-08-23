defmodule Gifmaster.Assets.CloudinaryTest do
  use ExUnit.Case, async: false

  alias Gifmaster.Assets.Cloudinary

  setup do
    previous_config = Application.get_env(:gifmaster, Cloudinary)

    Application.put_env(:gifmaster, Cloudinary,
      cloud_name: "demo",
      api_key: "key",
      api_secret: "secret",
      folder: "gifmaster/test",
      request_options: [plug: {Req.Test, __MODULE__}]
    )

    on_exit(fn -> restore_config(previous_config) end)
    :ok
  end

  test "uploads an overwrite and returns reconciliation metadata" do
    Req.Test.stub(__MODULE__, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      assert ["Basic " <> credentials] = Plug.Conn.get_req_header(conn, "authorization")
      assert "key:secret" == Base.decode64!(credentials)
      assert body =~ "gifmaster/test"
      assert body =~ "overwrite"
      assert body =~ "invalidate"
      assert body =~ "example"

      Req.Test.json(conn, %{
        public_id: "gifmaster/test/example",
        asset_id: "asset-id",
        secure_url: "https://res.cloudinary.com/demo/image/upload/example.gif",
        etag: "delivery-etag",
        version: 1234,
        format: "gif",
        bytes: 11,
        width: 640,
        height: 480
      })
    end)

    assert {:ok,
            %{
              provider: :cloudinary,
              cloudinary_public_id: "gifmaster/test/example",
              cloudinary_asset_id: "asset-id",
              cloudinary_version: "1234",
              delivery_url: "https://res.cloudinary.com/demo/image/upload/example.gif",
              delivery_etag: "delivery-etag",
              format: "gif",
              byte_count: 11,
              width: 640,
              height: 480
            }} =
             Cloudinary.upload("image-bytes",
               filename: "example.gif",
               content_type: "image/gif",
               public_id: "example"
             )
  end

  test "returns Cloudinary failures" do
    Req.Test.stub(__MODULE__, fn conn ->
      conn
      |> Plug.Conn.put_status(401)
      |> Req.Test.json(%{error: %{message: "bad credentials"}})
    end)

    assert {:error, {:http_error, 401, %{"error" => %{"message" => "bad credentials"}}}} =
             Cloudinary.upload("image-bytes", filename: "example.gif", public_id: "example")
  end

  test "verifies deterministic delivery bytes" do
    Req.Test.stub(__MODULE__, fn conn ->
      assert "/demo/image/upload/gifmaster/test/example.gif" == conn.request_path
      Plug.Conn.send_resp(conn, 200, "image-bytes")
    end)

    assert :ok == Cloudinary.verify_delivery("image-bytes", "example.gif")
  end

  test "rejects a deterministic delivery with different bytes" do
    Req.Test.stub(__MODULE__, fn conn -> Plug.Conn.send_resp(conn, 200, "different-bytes") end)

    assert {:error, :delivered_hash_mismatch} ==
             Cloudinary.verify_delivery("image-bytes", "example.gif")
  end

  defp restore_config(nil), do: Application.delete_env(:gifmaster, Cloudinary)
  defp restore_config(config), do: Application.put_env(:gifmaster, Cloudinary, config)
end
