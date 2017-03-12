defmodule Mirror.Billing do
  use Mirror.Web, :model

  alias Mirror.{Repo, Card, Organization}

  def add_payment(customer, source) do
      Stripe.Cards.create(:customer, customer, %{source: source})
  end

  def update_default_payment(customer, new_default_source) do
      Stripe.Customers.update(customer, %{default_source: new_default_source})
  end

  def delete_payment(customer, source) do
      Stripe.Cards.delete(:customer, customer, source)
  end
end
