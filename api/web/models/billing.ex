defmodule Mirror.Billing do
  use Mirror.Web, :model

  import Logger

  alias Mirror.{Repo, Card, Organization, Team, Helpers}

  def add_payment(customer, source) do
      Stripe.Cards.create(:customer, customer, %{source: source})
  end

  def update_default_payment(customer, new_default_source) do
      Stripe.Customers.update(customer, %{default_source: new_default_source})
  end

  def delete_payment(customer, source) do
      Stripe.Cards.delete(:customer, customer, source)
  end

  def is_active?(%Team{organization_id: organization_id}) do
      Logger.warn "test1"
      case organization_id do
          nil -> false
          _ -> is_active?(Repo.get!(Organization, organization_id))
      end
  end

  def is_active?(%Organization{billing_customer: billing_customer}) do
      Logger.warn "test2"
      case billing_customer do
          nil -> false
          _ -> is_stripe_active?(billing_customer)
      end
  end

  def is_stripe_active?(billing_customer) do
      Logger.warn "test3"
      {:ok, subscriptions} = Stripe.Subscriptions.all(billing_customer)
      subscriptions = Helpers.atomic_map(subscriptions)

      subscription = hd(subscriptions)
      subscription.status == "trialing" || subscription.status == "active"
  end
end
