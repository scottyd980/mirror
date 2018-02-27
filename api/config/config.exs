# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mirror,
  ecto_repos: [Mirror.Repo]

# Configures the endpoint
config :mirror, Mirror.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tsz0xVJbIMUVrpgZh47DvpIEjygMek+MvwbCx0qvJX5bkcbuQilUK6QY2e3nxf+Q",
  render_errors: [view: Mirror.ErrorView, accepts: ~w(json json-api)],
  pubsub: [name: Mirror.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mirror, Mirror.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: "***MAILGUN_API_KEY***",
  domain: "***MAIL_DOMAIN***"

config :phoenix, :format_encoders,
  "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :stripity_stripe, secret_key: "***STRIPE_API_KEY***"

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Mirror",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: System.get_env("GUARDIAN_SECRET") || "***GUARDIAN_SECRET***",
  serializer: Mirror.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
