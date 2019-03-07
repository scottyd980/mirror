# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mirror,
  ecto_repos: [Mirror.Repo]

config :phoenix, :json_library, Jason

# Configures the endpoint
config :mirror, MirrorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "MZh10vXebi5sBh8qXKuvIhbpcCwWUcyC5hh9tFNfdpjVNIxYZ++kw1zept3gmNWu",
  render_errors: [view: MirrorWeb.ErrorView, accepts: ~w(json json-api)],
  pubsub: [name: Mirror.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :mirror, Mirror.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: "key-96e671978cde9c46125523b1588cbd4d",
  domain: "mail.usemirror.io"

config :stripity_stripe,
  api_key: "sk_test_olzWYbRvUnGfyAbvOMtYvW79",
  webhook_secret: "whsec_0bUTjwUFxzvU5jplnO911pFigZNJJHLd"

config :phoenix, :format_encoders,
  "json-api": Jason

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :mirror,
  url_base: "http://localhost:4200"

config :mirror,
  billing_active: false

config :statix,
  prefix: "mirror_app.#{Mix.env}",
  host: "localhost",
  port: 8125

config :instruments,
  reporter_module: Instruments.Statix,
  statsd_port: 8125,
  disabled: false

config :mirror, Mirror.Guardian,
  issuer: "Mirror",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: System.get_env("GUARDIAN_SECRET") || "nGeq4o2xpePnwn46bhB4ItyiuiwM3doUuWi5T7yprcbWtF0xdpB5DqjkAEa6/2a/"

config :timber,
  api_key: "11066_bb4e9270d05296de:117e4a52c2e7b474cd6835b7e464ee7f85cd5619b74c31263ec987e113aa7687"

config :mirror, Mirror.Guardian.AuthPipeline,
  module: Mirror.Guardian,
  error_handler: Mirror.Guardian.AuthErrorHandler
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
