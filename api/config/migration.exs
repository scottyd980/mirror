use Mix.Config

# Configure your database
config :mirror, Mirror.Repo,
  hostname: System.get_env("DB_HOST"),
  username: System.get_env("USERNAME"),
  password: System.get_env("PASSWORD"),
  database: System.get_env("DATABASE"),
  pool_size: 20,
  ownership_timeout: 60_000
