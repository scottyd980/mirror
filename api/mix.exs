defmodule Mirror.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mirror,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Mirror.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:phoenix_html, "~> 2.11.2"},
      {:mariaex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:cors_plug, "~> 1.5"},
      {:guardian, "~> 1.0"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:ja_serializer, "~> 0.13.0"},
      {:hashids, "~> 2.0"},
      {:bamboo, "~> 0.8"},
      {:bamboo_smtp, "~> 1.4.0"},
      {:timex, "~> 3.1"},
      {:uuid, "~> 1.1"}
    ]



    # [
    #   {:phoenix, "~> 1.3.0-rc", override: true},
    #  {:phoenix_pubsub, "~> 1.0"},
    #  {:phoenix_ecto, "~> 3.0"},
    #  {:phoenix_live_reload, "~> 1.0"},
    #  {:phoenix_html, "~> 2.9.3"},
    #  {:mariaex, ">= 0.0.0"},
    #  {:gettext, "~> 0.11"},
    #  {:cowboy, "~> 1.0"},
    #  {:cors_plug, "~> 1.1"},
    #  {:guardian, "~> 0.13.0"},
    #  {:comeonin, "~> 2.5"},
    #  {:ja_serializer, "~> 0.11.0"},
    #  {:hashids, "~> 2.0"},
    #  {:excoveralls, "~> 0.5", only: :test},
    #  {:distillery, "~> 1.0"},
    #  {:bamboo, "~> 0.7"},
    #  {:bamboo_smtp, "~> 1.2.1"},
    #  {:stripity_stripe, "~> 1.4.0"},
    #  {:poison, "~> 2.2", override: true},
    #  {:hackney, "~> 1.7", override: true},
    #  {:httpoison, "~> 0.11", override: true},
    #  {:atomic_map, "~> 0.9"},
    #  {:timex, "~> 3.0"}
    # ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
