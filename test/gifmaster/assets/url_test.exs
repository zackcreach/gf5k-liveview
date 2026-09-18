defmodule Gifmaster.Assets.UrlTest do
  use ExUnit.Case, async: false

  alias Gifmaster.Assets.Url

  setup do
    original_imgproxy = Application.get_all_env(:imgproxy)
    original_base_url = Application.get_env(:gifmaster, :media_base_url)

    Application.put_all_env(
      imgproxy: [
        prefix: "https://images.prominent.tools/transform",
        key: String.duplicate("01", 32),
        salt: String.duplicate("02", 32)
      ],
      gifmaster: [media_base_url: "https://images.prominent.tools"]
    )

    on_exit(fn ->
      Application.put_all_env(imgproxy: original_imgproxy, gifmaster: [media_base_url: original_base_url])
    end)

    :ok
  end

  test "builds a signed animated preview with a versioned cache key" do
    first = Url.animated_preview_url("originals/ab/example.gif", "one")
    second = Url.animated_preview_url("originals/ab/example.gif", "two")

    assert String.starts_with?(first, "https://images.prominent.tools/transform/")
    assert String.ends_with?(first, ".webp")
    refute String.contains?(first, "/insecure/")
    refute first == second
  end

  test "rejects traversal and unsupported variants" do
    assert_raise ArgumentError, fn -> Url.original_url("../example.gif") end

    assert_raise ArgumentError, fn ->
      Url.variant_url("originals/example.gif",
        width: 2000,
        height: 480,
        fit: :fit,
        quality: 82,
        format: :webp,
        version: "one"
      )
    end

    assert_raise ArgumentError, fn ->
      Url.variant_url("originals/example.gif",
        width: 480,
        height: 480,
        fit: :fit,
        quality: 82,
        format: :gif,
        version: "one"
      )
    end
  end
end
