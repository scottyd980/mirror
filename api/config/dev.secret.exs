use Mix.Config

# Configure your database
config :mirror, Mirror.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "password",
  database: "mirror_dev",
  hostname: "localhost",
  pool_size: 10
