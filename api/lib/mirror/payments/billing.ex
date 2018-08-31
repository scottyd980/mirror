defmodule Mirror.Payments.Billing do
  alias Mirror.Organizations
  alias Mirror.Organizations.Organization
  alias Mirror.Payments.{Card, Billing}
  alias Mirror.Teams.Team

  require Logger

  def set_default_payment(organization) do
    org = organization
    |> Organization.preload_relationships

    case org.default_payment do
      nil -> {:ok, nil}
      payment -> Stripe.Customer.update(org.billing_customer, %{default_source: payment.card_id})
    end
  end

  def setup_subscriptions(organization) do
    organization = organization 
    |> Organization.preload_relationships()

    resp = case organization.default_payment_id do
      nil -> delete_subscriptions(organization)
      _ ->
        case organization.billing_frequency do
          nil -> delete_subscriptions(organization)
          "none" -> delete_subscriptions(organization)
          _ ->
            {:ok, existing_subs} = Stripe.Subscription.list(%{customer: organization.billing_customer})

            Enum.map(organization.teams, fn(team) ->
              Billing.upsert_subscription(organization, team, existing_subs)
            end)
        end
    end

    {:ok, resp}
  end

  def tear_down_subscriptions(organization) do
    case is_nil(organization) do
      true -> {:ok, nil}
      _ ->
        organization = Organizations.get_organization!(organization.uuid)
        |> Organization.preload_relationships()

        {:ok, existing_subs} = Stripe.Subscription.list(%{customer: organization.billing_customer})

        old_subscriptions = Enum.filter(existing_subs.data, fn(sub) ->
          !Enum.any?(organization.teams, fn(team) -> 
            String.to_integer(sub.metadata["team"]) == team.id
          end)
        end)

        resp = Billing.delete_subscriptions(organization, old_subscriptions)

        {:ok, resp}
    end
  end

  def upsert_subscription(organization, team, existing_subscriptions) do
    existing_sub = Enum.find(existing_subscriptions.data, fn(sub) ->
      String.to_integer(sub.metadata["team"]) == team.id
    end)

    case existing_sub do
      %{} = subscription ->
        Billing.update_subscription(subscription, organization, team)
      _ ->
        Billing.create_subscription(organization, team)
    end
  end

  def create_subscription(organization, team) do
    new_sub = get_new_subscription(organization, team)
    
    # Make sure right now is less than the end time for the trial period
    new_sub = case Team.in_trial_period?(team) do
      {true, trial_end} ->
        new_sub
        |> Map.put(:trial_end, trial_end)
      _ -> new_sub
    end
            
    Stripe.Subscription.create(new_sub)
  end

  def update_subscription(existing_subscription, organization, team) do
    updated_sub = %{
      cancel_at_period_end: false
    }

    updated_sub = case Team.in_trial_period?(team) do
      {true, trial_end} ->
        updated_sub
        |> Map.put(:trial_end, trial_end)
      _ -> updated_sub
    end

    Stripe.Subscription.update(existing_subscription.id, updated_sub)
  end

  def delete_subscriptions(organization) do
    {:ok, existing_subs} = Stripe.Subscription.list(%{customer: organization.billing_customer})

    delete_subscriptions(organization, existing_subs.data)
  end

  def delete_subscriptions(organization, subscriptions) do
    Enum.each(subscriptions, fn(sub) ->
      delete_subscription(organization, sub)
    end)
  end
  
  defp delete_subscription(organization, subscription) do
    Stripe.Subscription.delete(subscription.id, %{at_period_end: true})
  end

  defp get_new_subscription(organization, team) do
    %{
      customer: organization.billing_customer,
      items: [
        %{
          plan: Billing.map_plan(organization.billing_frequency),
          quantity: 1
        }
      ],
      metadata: %{
        team: team.id
      }
    }
  end
  
  def map_plan(billing_frequency) do
    case billing_frequency do
      "monthly" -> "basic-monthly"
      "yearly" -> "basic-yearly"
      _ -> nil
    end
  end

  def get_subscription_item(subscription) do
    hd(subscription.items.data)
  end
end
