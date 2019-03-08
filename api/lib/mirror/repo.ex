defmodule Mirror.Repo do
  use Ecto.Repo,
    otp_app: :mirror,
    adapter: Ecto.Adapters.MySQL

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  #
  def init(_, config) do
    if config[:ssl] do
      cert_dir = Application.app_dir(:mirror, "priv/ssl")
      ssl_opts = [cacertfile: Path.join(cert_dir, "ca.pem"),
                  certfile: Path.join(cert_dir, "client-cert.pem"),
                  keyfile: Path.join(cert_dir, "client-key.pem")]
      opts = [ssl_opts: ssl_opts] ++ config
      {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
    else
      {:ok, Keyword.put(config, :url, System.get_env("DATABASE_URL"))}
    end
  end
end
