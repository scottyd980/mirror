defmodule Mirror.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Mirror.Repo, []),
      # Start the endpoint when the application starts
      supervisor(MirrorWeb.Endpoint, []),
      # Start your own worker by calling: Mirror.Worker.start_link(arg1, arg2, arg3)
      # worker(Mirror.Worker, [arg1, arg2, arg3]),
    ]

    setup_probes()
    Timber.Phoenix.add_controller_to_blacklist(MirrorWeb.HealthController)

    :ok = :telemetry.attach(
      "timber-ecto-query-handler",
      [:mirror, :repo, :query],
      &Timber.Ecto.handle_event/4,
      [query_time_ms_threshold: 1_000]
    )

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mirror.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MirrorWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def setup_probes() do
    if Application.get_env(:instruments, :disabled) != true do
      {:ok, _} = Application.ensure_all_started(:instruments)
      interval = 1_000

      Instruments.Probe.define(
        "erlang.process_count",
        :gauge,
        mfa: {:erlang, :system_info, [:process_count]},
        report_interval: interval
      )

      Instruments.Probe.define(
        "erlang.memory",
        :gauge,
        mfa: {:erlang, :memory, []},
        keys: [:total, :atom, :processes],
        report_interval: interval
      )

      Instruments.Probe.define(
        "erlang.statistics.run_queue",
        :gauge,
        mfa: {:erlang, :statistics, [:run_queue]},
        report_interval: interval
      )

      Instruments.Probe.define(
        "erlang.system_info.process_count",
        :gauge,
        mfa: {:erlang, :system_info, [:process_count]},
        report_interval: interval
      )
    end
  end
end
