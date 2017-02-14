use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :mirror, Mirror.Endpoint,
  http: [port: 4000],
  #debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :phoenix_distillery, PhoenixDistillery.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "localhost", port: {:system, "PORT"}], # This is critical for ensuring web-sockets properly authorize.
  server: true,
  root: ".",
  version: Mix.Project.config[:version]


# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

import_config "dev.secret.exs"
