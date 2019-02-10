defmodule Mirror.Helpers.Card do
  alias Mirror.Payments
  alias Mirror.Payments.Card

  def is_expired?(struct) do
    last_day = Calendar.ISO.days_in_month(struct.exp_year, struct.exp_month)
    {:ok, expiration_date} = Date.new(struct.exp_year, struct.exp_month, last_day)
    today = Date.utc_today()
    case Date.compare(expiration_date, today) do
      :lt -> true
      _ -> false
    end
  end
end
