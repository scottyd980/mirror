defmodule Mirror.Billing do
  use Mirror.Web, :model

  alias Mirror.{Repo, Card, Organization}

  def update_default_payment(customer, new_default_source) do
    Stripe.Customers.update(customer, %{default_source: new_default_source})
  end
end
