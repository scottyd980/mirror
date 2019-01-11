defmodule MirrorWeb.Parsers.Webhook do
  @behaviour Plug.Parsers
  alias Plug.Conn

  require Logger

  def parse(%{request_path: "/api/stripe_webhooks"} = conn, _type, _subtype, _headers, opts) do
    do_parse(conn, opts)
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  defp do_parse(conn, opts) do
    case Conn.read_body(conn, opts) do
      {:ok, body, conn} ->
        {:ok, %{raw: body}, conn}
      {:more, _data, conn} ->
        {:error, :too_large, conn}
    end
  end

end