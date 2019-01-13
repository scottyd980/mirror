defmodule MirrorWeb.WebhookController do
  use MirrorWeb, :controller

  alias Mirror.Helpers
  alias Mirror.Payments
  alias Mirror.Payments.{Event}
  alias Mirror.Organizations
  alias Mirror.Organizations.Organization
  alias Mirror.Teams.Team

  require Logger

  action_fallback MirrorWeb.FallbackController

  def create(conn, params) do
    payload = params.raw
    signature = hd(Plug.Conn.get_req_header(conn, "stripe-signature"))
    secret = Application.get_env(:stripity_stripe, :webhook_secret)

    case Stripe.Webhook.construct_event(payload, signature, secret) do
      {:ok, %Stripe.Event{} = event} ->
        # Return 200 to Stripe and handle event
        Task.start(fn -> process_stripe_event(event) end)
        conn
        |> put_status(:ok)
        |> json(%{})

      {:error, reason} ->
        # Reject webhook by responding with non-2XX
        conn
        |> put_status(:unprocessable_entity)
        |> json(reason)
    end
  end

  defp process_stripe_event(event) do
    case Payments.get_event(event.id) do
      %Event{} = event ->
        Logger.warn "Already exists, do not re-process"
        :noreply
      nil ->
        Logger.info "WEBHOOK"
        Logger.warn "#{inspect event}"
        Payments.create_event(%{event_id: event.id})
        initiate_internal_events(event)
    end

    :noreply
  end

  defp initiate_internal_events(event) do
    case event.type do
      "invoice.payment_succeeded" -> process_successful_payment(event)
      "invoice.payment_failed" -> handle_failed_payment(event)
      _ -> nil
    end
  end

  defp process_successful_payment(event) do
    line_items = event.data.object.lines.data

    #TODO: Look at customer here instead

    Enum.each(line_items, fn(line_item) ->
      case Stripe.Subscription.retrieve(line_item.subscription) do
        {:ok, sub} ->
          organization = Organizations.get_organization_by_customer_id!(sub.customer)
          case organization do
            %Organization{} ->
              org = organization |> Organization.preload_relationships()

              Organization.update_subscription_period(org, %{
                period_end: sub.current_period_end
              })

              Enum.each(org.teams, fn team ->
                Team.update_subscription_period(team, %{
                  period_end: sub.current_period_end
                })
              end)
            _ -> Logger.error "No organization found with customer id: #{sub.customer} for subscription: #{sub.id}"
          end
        _ -> Logger.error "Stripe unable to find subscription: #{line_item.subscription}"
      end
    end)
  end

  defp handle_failed_payment(event) do
    Logger.error "PAYMENT FAILED"
    Logger.warn "#{inspect event}"
  end
end
