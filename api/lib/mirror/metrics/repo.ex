defmodule Mirror.Metrics.Repo do
  use Instruments

  def record_metric(entry) do
    if Application.get_env(:instruments, :disabled) != true do
      Instruments.Statix.histogram("query_exec_time", entry.query_time + (entry.queue_time || 0))
      Instruments.Statix.histogram("query_queue_time", (entry.queue_time || 0))
      Instruments.Statix.increment("query_count")
    end
  end
end
