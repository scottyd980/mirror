defmodule Mirror.Guardian.AuthErrorHandler do
    use Phoenix.Controller
    import Plug.Conn

    def auth_error(conn, _error, _opts) do
        conn
        |> put_status(401)
        |> render(MirrorWeb.ErrorView, "401.json-api")
    end
end