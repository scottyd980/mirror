defmodule Mirror.Billing do
  use Mirror.Web, :model

  import Logger

  alias Mirror.{Repo, Card, Organization, Team, Helpers}

  def add_payment(customer, source) do
      Stripe.Cards.create(:customer, customer, %{source: source})
  end

  def add_subscription(customer) do
      {:ok, subscriptions} = Stripe.Subscriptions.all(customer.billing_customer)
      subscriptions = Helpers.atomic_map(subscriptions)

      case length(subscriptions) > 0 do
        true ->
          update_subscription(customer, hd(subscriptions))
        _ ->
          create_subscription(customer)
      end
  end

  defp create_subscription(customer) do
      Logger.warn "#{inspect customer.teams}"

      new_sub = [
        plan: "basic-monthly",
        quantity: 1
      ]

      now = Timex.Duration.now(:seconds)
      trial_end = Team.get_trial_period_end(hd(customer.teams))

      # Make sure right now + 60s (for request offset) is less than the end time for the trial period
      new_sub = case (now - 60) < trial_end do
          true ->
            new_sub ++ [trial_end: trial_end]
          _ ->
            new_sub
      end

      Stripe.Subscriptions.create(customer.billing_customer, new_sub)
  end

  defp update_subscription(customer, subscription) do
      Logger.warn "#{inspect subscription}"
      Logger.warn "Test2"
  end

  def update_default_payment(customer, new_default_source) do
      Stripe.Customers.update(customer, %{default_source: new_default_source})
  end

  def delete_payment(customer, source) do
      Stripe.Cards.delete(:customer, customer, source)
  end

  def is_active?(%Team{organization_id: organization_id}) do
      case organization_id do
          nil -> false
          _ -> is_active?(Repo.get!(Organization, organization_id))
      end
  end

  def is_active?(%Organization{billing_customer: billing_customer}) do
      case billing_customer do
          nil -> false
          _ -> is_billing_active?(billing_customer)
      end
  end

  def is_billing_active?(billing_customer) do
    {:ok, subscriptions} = Stripe.Subscriptions.all(billing_customer)
    subscriptions = Helpers.atomic_map(subscriptions)
    cond do
        length(subscriptions) > 0 ->
            subscription = hd(subscriptions)
            subscription.status == "trialing" || subscription.status == "active"
        true ->
            false
    end
  end
end
