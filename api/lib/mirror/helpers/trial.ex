defmodule Mirror.Helpers.Trial do
  @trial_period 2678400

  def create_end_date() do
    DateTime.to_unix(DateTime.utc_now()) + @trial_period
  end
end
