defmodule MirrorWeb.HealthController do
  use MirrorWeb, :controller

  require Logger

  action_fallback MirrorWeb.FallbackController

  def index(conn, _params) do
    Logger.warn "#{inspect conn}"

    conn
    |> put_status(200)
    |> json(%{status: "healthy", time: DateTime.utc_now})
  end
end
