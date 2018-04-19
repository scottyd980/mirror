defmodule Mirror.Billing do
    use Mirror.Web, :model
    
    import Logger
    
    alias Mirror.{Repo, Card, Organization, Team, Helpers}
    
    def add_payment(customer, source) do
        Stripe.Cards.create(:customer, customer, %{source: source})
    end
    
    def build_subscriptions(customer) do
        case is_nil(customer) do
            true -> nil
            _ ->
                customer = customer |> Organization.preload_relationships

                case customer.default_payment_id do
                    nil -> cancel_subscriptions(customer)
                    _ ->
                        case get_billing_frequency(customer) do
                            nil -> cancel_subscriptions(customer)
                            "none" -> cancel_subscriptions(customer)
                            _ ->
                                {:ok, subscriptions} = Stripe.Subscriptions.all(customer.billing_customer)
                                existing_subs = Helpers.atomic_map(subscriptions)

                                Enum.map(customer.teams, fn(team) ->
                                    build_subscription(customer, team, existing_subs)
                                end)
                        end 
                end
        end
    end

    def remove_subscription(customer, team) do
        remove_subscription(customer, team, false)
    end

    def remove_subscription(customer, team, force_remove) do
        case is_nil(customer) do
            true -> nil
            _ ->
                case (team.organization_id == customer.id) && !force_remove do
                    true -> nil
                    _ ->
                        {:ok, subscriptions} = Stripe.Subscriptions.all(customer.billing_customer)
                        existing_subs = Helpers.atomic_map(subscriptions)

                        existing_sub = Enum.find(existing_subs, fn(sub) ->
                            String.to_integer(sub.metadata.team) == team.id
                        end)

                        case existing_sub do
                            %{} = subscription ->
                                cancel_subscription(customer, subscription)
                            _ ->
                                nil
                        end
                end
        end
    end

    def remove_subscriptions(customer) do
        cancel_subscriptions(customer)
    end

    defp build_subscription(customer, team, existing_subs) do
        existing_sub = Enum.find(existing_subs, fn(sub) ->
            String.to_integer(sub.metadata.team) == team.id
        end)

        case existing_sub do
            %{} = subscription ->
                update_subscription(subscription, customer, team)
            _ ->
                create_subscription(customer, team)
        end
    end

    defp update_subscription(existing_subscription, customer, team) do
        updated_sub = [
            plan: get_billing_frequency(customer)
        ]

        updated_sub = case in_trial_window?(team) do
            {true, trial_end} ->
                updated_sub ++ [trial_end: trial_end]
            _ ->
                updated_sub
        end

        # Making the request with the lower level API for now
        response = Stripe.make_request_with_key(:post, "customers/#{customer.billing_customer}/subscriptions/#{existing_subscription.id}", Stripe.config_or_env_key, updated_sub)
        |> Stripe.Util.handle_stripe_response
    end
            
    defp create_subscription(customer, team) do
        new_sub = [
            plan: get_billing_frequency(customer),
            quantity: 1,
            metadata: %{
                team: team.id
            }
        ]
        
        # Make sure right now + 60s (for request offset) is less than the end time for the trial period
        new_sub = case in_trial_window?(team) do
            {true, trial_end} ->
                new_sub ++ [trial_end: trial_end]
            _ ->
                new_sub
        end
                
        Stripe.Subscriptions.create(customer.billing_customer, new_sub)
    end

    defp cancel_subscription(customer, subscription) do
        Stripe.Subscriptions.cancel(customer.billing_customer, subscription.id)
    end

    defp cancel_subscriptions(customer) do
        Stripe.Subscriptions.cancel_all(customer.billing_customer, [at_period_end: true]);
    end

    defp in_trial_window?(team) do
        now = Timex.Duration.now(:seconds)
        trial_end = Team.get_trial_period_end(team)

        {(now - 60) < trial_end, trial_end}
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

    defp get_billing_frequency(customer) do
        case customer.billing_frequency do
            "none" -> nil
            "monthly" -> "basic-monthly"
            "yearly" -> "basic-yearly"
        end
    end
end
                