defmodule MirrorWeb.UUIDController do
  use MirrorWeb, :controller

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def index(conn, _params) do
    conn
    |> json(%{ hash: Helpers.Hash.generate_unique_id() })
  end
end
