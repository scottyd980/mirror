defmodule Mirror.Payments.Billing do
  alias Mirror.Organizations
  alias Mirror.Organizations.Organization
  alias Mirror.Payments.{Card, Billing}
  alias Mirror.Teams
  alias Mirror.Teams.Team
  alias Mirror.Helpers

  require Logger

  # We add 7 days of tolerancy for plan payments
  @tolerancy_period 604_800
  @timeout 30_000

  @doc """
  Processes a subscription for an organization.

  ## Usage
  - Main interface to billing, this function decides if there was an existing subscription, if a subscription is needed at this time,
  and how to process a subscription for a given organiation.

  ## Examples

    iex> process_subscription(organization)
    {:ok, :updated}

    iex> process_subscription(organization)
    {:error, :failure_reason}

  """
  def process_subscription(organization, frequency_updated \\ false) do
    organization = organization |> Organization.preload_relationships()
    {:ok, existing_subs} = Stripe.Subscription.list(%{customer: organization.billing_customer})
    organization_status = get_organization_status!(existing_subs)

    num_teams = length(organization.teams)
    num_subs = length(existing_subs.data)

    # TODO: Need to handle removing credit card
    case organization_status do
      :new ->
        case num_teams > 0 && organization.billing_status == "active" do
          false -> {:ok, nil}
          true -> create_subscription(organization)
        end
      :existing ->
        subscription = hd(existing_subs.data)
        num_sub_items = hd(subscription.items.data).quantity
        case organization.billing_status do
          "inactive" -> delete_subscription(organization, subscription)
          "active" ->
            case frequency_updated do
              true -> update_subscription_plan(organization, subscription)
              _ -> nil
            end
            cond do
              num_teams == 0 -> delete_subscription(organization, subscription)
              num_teams == num_sub_items -> {:ok, existing_subs}
              num_teams > num_sub_items -> update_subscription_quantity(organization, hd(existing_subs.data), true)
              num_teams < num_sub_items -> update_subscription_quantity(organization, hd(existing_subs.data), false)
            end
        end
    end
  end

  defp get_organization_status!(existing_subs) do
    case length(existing_subs.data) do
      0 -> :new
      _ -> :existing
    end
  end

  @doc """
  Creates a subscription for an organization.

  ## Usage
  - Organization which already has teams associated with it finalizes its billing preferences by adding a payment source AND updating
    its frequency (to anything other than TRIAL).

  - Organization which already has its billing preferences finalized (payment source added and frequency !== TRIAL) adds its first team.

  - Organization has not yet passed its trial period, so billing should not occur until after the trial period expires.

  - Organization updates frequency. Since we do not pro-rate frequency changes, we instead re-create a subscription with the new
    frequency and trial_period_end set to the period_end of its current subscription, so a charge is not initiated until the last
    pay period ends.

  - Organization removes a team. Since teams are paid for in full at the beginning of the period, no refunds occur. In order to handle
    this we need to cancel and re-create a subscription with a different number of teams. We set the trial_period_end to period_end of
    the existing subscription, so a charge is not initiated until the last pay period ends.

  ## Examples

      iex> create_subscription(organization)
      {:ok, %Stripe.Subscription{}}

      iex> create_subscription(organization)
      {:error, %Stripe.Error{}}

  """
  def create_subscription(organization) do
    new_sub = generate_new_subscription(organization)

    Stripe.Subscription.create(new_sub)
  end

  @doc """
  Updates a subscription item for an organization.

  ## Usage
  - A new team is created, and needs to be added to a subscription. This will increase the quantity of subscrietion items for an
    organization's subscription. It will pro-rate the billing period for the new subscription item.

  - A team is removed from an organization and needs to be removed from a subscription. This will reduce the quantity of subscription
    items for an organization's subscription. It will NOT pro-rate the billing period for the old subscription item.

  ## Examples

      iex> update_subscription_quantity(organization, subscription, true)
      {:ok, %Stripe.SubscriptionItem{}}

      iex> update_subscription_quantity(organization, subscription, false)
      {:ok, %Stripe.SubscriptionItem{}}

      iex> update_subscription_quantity(organization, subscription, true)
      {:error, %Stripe.Error{}}

  """
  def update_subscription_quantity(organization, subscription, prorate \\ false) do
    num_teams = length(organization.teams)

    subscription_item = hd(subscription.items.data)

    Stripe.Subscription.update(subscription, %{
      items: [
        %{
          id: subscription_item.id,
          quantity: num_teams
        }
      ],
      prorate: prorate
    })
  end

  @doc """
  Deletes a subscription for an organization. If a subscription is passed, it will cancel the subscription with no other calls. If only an
  organization is passed, it will first look for a subscription attached to the organization, and then use that to delete the subscription.

  ## Usage
  - All teams are deleted

  - An organization is deleted

  - Billing frequency is set to "none"

  - No valid card on file

  ## Examples

      iex> delete_subscription(organization, subscription)
      {:ok, %Stripe.Subscription{}}

      iex> delete_subscription(organization)
      {:ok, %Stripe.Subscription{}}

      iex> delete_subscription(organization, subscription)
      {:error, %Stripe.Error{}}

      iex> delete_subscription(organization)
      {:error, :subscription_not_found}

  """
  def delete_subscription(organization, subscription \\ nil) do
    subscription = case subscription do
      nil ->
        {:ok, sub} = Stripe.Subscription.list(%{customer: organization.billing_customer})
        case length(sub.data) > 0 do
          true -> hd(sub.data)
          false -> :error
        end
      subscription -> subscription
    end

    case subscription do
      :error -> {:error, :subscription_not_found}
      _ -> Stripe.Subscription.delete(subscription.id)
    end
  end


  def update_subscription_plan(organization, subscription) do
    subscription_item = hd(subscription.items.data)
    Stripe.Subscription.update(subscription, %{
      cancel_at_period_end: false,
      items: [
        %{
          id: subscription_item.id,
          plan: map_plan(organization.billing_frequency)
        }
      ]
    })
  end

  @doc """
  Modifies the organizations default source (payment/credit card).

  ## Usage
  - Organization adds a new credit card and when that card is added, it needs to update to use that credit card as its default source.

  ## Examples

      iex> modify_source(organization)
      {:ok, %Stripe.Customer{}}

      iex> modify_source(organization)
      {:ok, nil}

      iex> modify_source(organization)
      {:error, %Stripe.Error{}}

  """
  def set_default_source(organization) do
    org = organization
    |> Organization.preload_relationships

    case org.default_payment do
      nil -> {:ok, nil}
      payment ->
        Logger.warn "#{inspect payment}"
        Stripe.Customer.update(org.billing_customer, %{default_source: payment.card_id})
    end
  end


  defp generate_new_subscription(organization) do
    org = organization
    |> Organization.preload_relationships

    %{
      customer: organization.billing_customer,
      trial_end: get_trial_end(organization.trial_end),
      items: [
        %{
          plan: map_plan(organization.billing_frequency),
          quantity: length(org.teams)
        }
      ]
    }
  end

  defp map_plan(billing_frequency) do
    case billing_frequency do
      "monthly" -> "mirror-monthly-10"
      "yearly" -> "mirror-yearly-100"
      _ -> nil
    end
  end

  defp get_trial_end(timestamp) do
    now = DateTime.to_unix(DateTime.utc_now())

    # Give ourselves a few (30) seconds to process the request, just in case
    case now >= timestamp - @timeout do
      true -> "now"
      false -> timestamp
    end
  end

end
