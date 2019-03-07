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
  secret_key_base: "***SECRET_KEY_BASE***",
  render_errors: [view: MirrorWeb.ErrorView, accepts: ~w(json json-api)],
  pubsub: [name: Mirror.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :mirror, Mirror.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: "***MAILGUN_API_KEY***",
  domain: "***MAIL_DOMAIN***"

config :stripity_stripe,
  api_key: "***STRIPE_API_KEY***",
  webhook_secret: "***STRIPE_WEBHOOK_SECRET***"

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
  secret_key: System.get_env("GUARDIAN_SECRET") || "***GUARDIAN_SECRET***"

config :timber,
  api_key: "***TIMBER_API_KEY***"

config :mirror, Mirror.Guardian.AuthPipeline,
  module: Mirror.Guardian,
  error_handler: Mirror.Guardian.AuthErrorHandler
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
