defmodule GifmasterWeb.HealthControllerTest do
  use GifmasterWeb.ConnCase, async: true

  test "returns success when the database is ready", %{conn: conn} do
    conn = get(conn, ~p"/health")

    assert %{"status" => "ok"} == json_response(conn, 200)
  end

  test "permanently redirects the www host and preserves the query", %{conn: conn} do
    conn =
      conn
      |> Map.put(:host, "www.gifmaster5000.com")
      |> get("/users/log_in?next=upload")

    assert 308 == conn.status
    assert "https://gifmaster5000.com/users/log_in?next=upload" == conn |> get_resp_header("location") |> List.first()
  end
end
