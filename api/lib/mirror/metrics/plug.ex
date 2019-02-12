defmodule Mirror.Metrics.Plug do
  @behaviour Plug
  import Plug.Conn, only: [register_before_send: 2]
  use Instruments

  def init(opts), do: opts

  def call(conn, _config) do
    req_start_time = :os.timestamp

    register_before_send conn, fn conn ->
      # increment count
      if Application.get_env(:instruments, :disabled) != true do
        Instruments.Statix.increment("resp_count")
      end

      # log response time in microseconds
      req_end_time = :os.timestamp
      duration = :timer.now_diff(req_end_time, req_start_time)
      if Application.get_env(:instruments, :disabled) != true do
        Instruments.Statix.histogram("resp_time", duration)
      end

      conn
    end
  end
end
