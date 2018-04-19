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
  api_key: "key-96e671978cde9c46125523b1588cbd4d",
  domain: "mail.usemirror.io"

config :phoenix, :format_encoders,
  "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :stripity_stripe, secret_key: "sk_test_olzWYbRvUnGfyAbvOMtYvW79"

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Mirror",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: System.get_env("GUARDIAN_SECRET") || "nGeq4o2xpePnwn46bhB4ItyiuiwM3doUuWi5T7yprcbWtF0xdpB5DqjkAEa6/2a/",
  serializer: Mirror.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"