defmodule MirrorWeb.HealthController do
  use MirrorWeb, :controller

  action_fallback MirrorWeb.FallbackController

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{status: "healthy", time: DateTime.utc_now})
  end
end
