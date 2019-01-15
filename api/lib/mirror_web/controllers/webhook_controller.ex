defmodule MirrorWeb.WebhookController do
  use MirrorWeb, :controller

  alias Mirror.Helpers
  alias Mirror.Payments
  alias Mirror.Payments.{Event, Card, Billing}
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
        Logger.warn "[WebhookController.process_stripe_event/1] Event already exists, do not re-process: #{inspect event}"
        :noreply
      nil ->
        Logger.warn "[WebhookController.process_stripe_event/1] Event does not exist, processing: #{inspect event}"
        Payments.create_event(%{event_id: event.id})
        initiate_internal_events(event)
    end

    :noreply
  end

  defp initiate_internal_events(event) do
    case event.type do
      "invoice.payment_succeeded" -> process_successful_payment(event)
      "invoice.payment_failed" -> process_failed_invoice(event)
      "customer.source.updated" -> process_card_update(event)
      "charge.failed" -> process_failed_charge(event)
      "customer.updated" -> process_customer_update(event)
      "customer.source.created" -> process_card_created(event)
      "customer.source.deleted" -> process_card_deleted(event)
      "customer.subscription.deleted" -> process_subscription_deleted(event)
      _ -> nil
    end
  end

  defp process_successful_payment(event) do
    line_items = event.data.object.lines.data

    Enum.each(line_items, fn(line_item) ->
      case Stripe.Subscription.retrieve(line_item.subscription) do
        {:ok, sub} ->
          case Organizations.get_organization_by_customer_id(sub.customer) do
            %Organization{} = organization ->
              org = organization |> Organization.preload_relationships()

              # TODO: Turn back on
              # Organization.update_via_webhook(org, %{
              #   period_end: sub.current_period_end
              # })

              # Enum.each(org.teams, fn team ->
              #   Team.update_via_webhook(team, %{
              #     period_end: sub.current_period_end
              #   })
              # end)

              Billing.process_subscription(org)
            _ -> Logger.error "[WebhookController.process_successful_payment/1] No organization found with customer id: #{sub.customer} for subscription: #{sub.id}"
          end
        _ -> Logger.error "[WebhookController.process_successful_payment/1] Stripe unable to find subscription: #{line_item.subscription}"
      end
    end)
  end

  defp process_failed_invoice(event) do
    # Handle for when an invoice payment fails -
    #%Stripe.Event{account: nil, api_version: "2018-11-08", created: 1547426992, data: %{object: %Stripe.Invoice{starting_balance: 0, period_start: 1547426761, attempt_count: 1, metadata: %{}, id: "in_1DsJdNEybvf9s0JUAhoXXzun", ending_balance: 0, subscription: "sub_EKzZsQpbaJzhVT", receipt_number: nil, tax_percent: nil, currency: "usd", period_end: 1547426937, due_date: 1550018988, closed: nil, livemode: false, amount_due: 10000, statement_descriptor: nil, subtotal: 10000, charge: "ch_1DsJeCEybvf9s0JUB7UpgYG3", next_payment_attempt: 1547639388, description: "", lines: %Stripe.List{data: [%Stripe.LineItem{amount: -10000, currency: "usd", description: "Unused time on Mirror Subscription after 14 Jan 2019", discountable: false, id: "ii_1DsJcrEybvf9s0JUJyA8KxpS", invoice_item: "ii_1DsJcrEybvf9s0JUJyA8KxpS", livemode: false, metadata: %{}, object: "line_item", period: %{end: 1578962761, start: 1547426905}, plan: %Stripe.Plan{aggregate_usage: nil, amount: 10000, billing_scheme: "per_unit", created: 1547169423, currency: "usd", id: "mirror-yearly-100", interval: "year", interval_count: 1, livemode: false, metadata: %{}, name: nil, ...}, proration: true, quantity: 1, subscription: "sub_EKzZsQpbaJzhVT", subscription_item: "si_EKzZvuklP8rmgl", type: "invoiceitem"}, %Stripe.LineItem{amount: 20000, currency: "usd", description: "Remaining time on 2 × Mirror Subscription after 14 Jan 2019", discountable: false, id: "ii_1DsJcrEybvf9s0JUNekvQy4m", invoice_item: "ii_1DsJcrEybvf9s0JUNekvQy4m", livemode: false, metadata: %{}, object: "line_item", period: %{end: 1578962761, start: 1547426905}, plan: %Stripe.Plan{aggregate_usage: nil, amount: 10000, billing_scheme: "per_unit", created: 1547169423, currency: "usd", id: "mirror-yearly-100", interval: "year", interval_count: 1, livemode: false, metadata: %{}, ...}, proration: true, quantity: 2, subscription: "sub_EKzZsQpbaJzhVT", subscription_item: "si_EKzZvuklP8rmgl", type: "invoiceitem"}], has_more: false, object: "list", total_count: 2, url: "/v1/invoices/in_1DsJdNEybvf9s0JUAhoXXzun/lines"}, subscription_proration_date: nil, tax: 0, attempted: true, billing: "charge_automatically", date: 1547426937, forgiven: nil, customer: "cus_EJsQbrH5LrsqUN", discount: nil, application_fee: nil, total: 10000, paid: false, object: "invoice", webhooks_delivered_at: 1547426940}}, id: "evt_1DsJeGEybvf9s0JUnPV1MHkB", livemode: false, object: "event", pending_webhooks: 1, request: %{id: nil, idempotency_key: nil}, type: "invoice.payment_failed"}

    invoice = event.data.object
    Logger.warn "[WebhookController.process_failed_invoice/1] Invoice (#{invoice.id}) payment failed: #{inspect event}"
  end

  defp process_failed_charge(event) do
    # Handle for when a charge fails - %Stripe.Event{account: nil, api_version: "2018-11-08", created: 1547426580, data: %{object: %Stripe.Charge{captured: false, metadata: %{}, balance_transaction: nil, amount_refunded: 0, id: "ch_1DsJXcEybvf9s0JUchNoIf9s", source: %Stripe.Card{account: nil, address_city: nil, address_country: nil, address_line1: nil, address_line1_check: nil, address_line2: nil, address_state: nil, address_zip: "27513", address_zip_check: "pass", available_payout_methods: nil, brand: "Visa", country: "US", currency: nil, customer: "cus_EJsQbrH5LrsqUN", cvc_check: nil, default_for_currency: nil, dynamic_last4: nil, exp_month: 4, exp_year: 2024, fingerprint: "19pKgq72Nrd1ThQe", funding: "credit", id: "card_1DsJTfEybvf9s0JUEW4ubXfg", last4: "0341", metadata: %{}, name: "Scott Douglass", object: "card", recipient: nil, tokenization_method: nil}, shipping: nil, receipt_number: nil, transfer: nil, refunded: false, currency: "usd", failure_code: "card_declined", review: nil, outcome: %{network_status: "declined_by_network", reason: "generic_decline", risk_level: "normal", risk_score: 6, seller_message: "The bank did not return any further details with this decline.", type: "issuer_declined"}, livemode: false, failure_message: "Your card was declined.", statement_descriptor: "MIRROR - SUBSCRIPTION", description: nil, order: nil, created: 1547426580, receipt_email: nil, fraud_details: %{}, dispute: nil, on_behalf_of: nil, refunds: %Stripe.List{data: [], has_more: false, object: "list", total_count: 0, url: "/v1/charges/ch_1DsJXcEybvf9s0JUchNoIf9s/refunds"}, amount: 1000, transfer_group: nil, application: nil, customer: "cus_EJsQbrH5LrsqUN", source_transfer: nil, application_fee: nil, destination: nil, paid: false, object: "charge", status: "failed", invoice: nil}}, id: "evt_1DsJXdEybvf9s0JUWfCkugQW", livemode: false, object: "event", pending_webhooks: 1, request: %{id: "req_alqRsvh4FRGrGe", idempotency_key: nil}, type: "charge.failed"}

    nil
  end

  defp process_customer_update(event) do
    customer = event.data.object

    org_updates = case Payments.get_card_by_card_id(customer.default_source) do
      %Card{} = card ->
        org_updates = %{
          default_payment_id: card.id,
          is_delinquent: customer.delinquent
        }
      _ ->
        Logger.error "[WebhookController.process_customer_update/1] No card found with card id: #{customer.default_source}"
        org_updates = %{
          is_delinquent: customer.delinquent
        }
    end

    organization = Organizations.get_organization_by_customer_id(customer.id)

    case organization do
      %Organization{} = org -> Organization.update_via_webhook(org, org_updates)
      _ -> Logger.error "[WebhookController.process_customer_update/1] No organization found with customer id: #{customer.id}"
    end
  end

  # Maybe we don't want this one at all
  defp process_card_created(event) do
    # card = event.data.object

    # case Payments.get_card_by_card_id(card.id) do
    #   {:ok, %Card{} = old_card} -> Logger.warn "[WebhookController.process_customer_update/1] Card (with database ID: #{old_card.id}) already exists for: #{inspect card}"
    #   _ ->
    #     case Organizations.get_organization_by_customer_id(card.customer) do
    #       {:ok, %Organization{} = organization} ->
    #         card_params = %{
    #           organization_id: organization.id,
    #           brand: card.brand,
    #           last4: card.last4,
    #           exp_month: card.exp_month,
    #           exp_year: card.exp_year,
    #           card_id: card.id,
    #           zip_code: card.address_zip
    #         }
    #         result = Payments.create_card(card_params, false)
    #         Logger.error "#{inspect result}"
    #       _ -> Logger.error "[WebhookController.process_card_created/1] No organization found with customer id: #{card.customer} for subscription: #{card.id}"
    #     end
    # end

    # Handle in case something goes wrong and we have a copy of the cc in stripe but not the database - %Stripe.Event{account: nil, api_version: "2018-11-08", created: 1547428020, data: %{object: %Stripe.Card{account: nil, address_city: nil, address_country: nil, address_line1: nil, address_line1_check: nil, address_line2: nil, address_state: nil, address_zip: "27513", address_zip_check: "pass", available_payout_methods: nil, brand: "Visa", country: "US", currency: nil, customer: "cus_EJsQbrH5LrsqUN", cvc_check: "pass", default_for_currency: nil, dynamic_last4: nil, exp_month: 4, exp_year: 2024, fingerprint: "bMbVQMwUIjmAzWYM", funding: "credit", id: "card_1DsJupEybvf9s0JUDbGTyAKP", last4: "4242", metadata: %{}, name: "Scott Douglass", object: "card", recipient: nil, tokenization_method: nil}}, id: "evt_1DsJuqEybvf9s0JUC3mJOCHK", livemode: false, object: "event", pending_webhooks: 1, request: %{id: "req_9Vkgh6UAuQ5K4K", idempotency_key: nil}, type: "customer.source.created"}

    nil
  end

  defp process_card_deleted(event) do
    # Handle in case something goes wrong and we have a copy of the cc in database but not in stripe anymore - %Stripe.Event{account: nil, api_version: "2018-11-08", created: 1547428020, data: %{object: %Stripe.Card{account: nil, address_city: nil, address_country: nil, address_line1: nil, address_line1_check: nil, address_line2: nil, address_state: nil, address_zip: "27513", address_zip_check: "pass", available_payout_methods: nil, brand: "Visa", country: "US", currency: nil, customer: "cus_EJsQbrH5LrsqUN", cvc_check: "pass", default_for_currency: nil, dynamic_last4: nil, exp_month: 4, exp_year: 2024, fingerprint: "bMbVQMwUIjmAzWYM", funding: "credit", id: "card_1DsJupEybvf9s0JUDbGTyAKP", last4: "4242", metadata: %{}, name: "Scott Douglass", object: "card", recipient: nil, tokenization_method: nil}}, id: "evt_1DsJuqEybvf9s0JUC3mJOCHK", livemode: false, object: "event", pending_webhooks: 1, request: %{id: "req_9Vkgh6UAuQ5K4K", idempotency_key: nil}, type: "customer.source.deleted"}

    nil
  end

  defp process_subscription_deleted(event) do
    subscription = event.data.object

    Logger.error "#{inspect Organizations.get_organization_by_customer_id(subscription.customer)}"

    case Organizations.get_organization_by_customer_id(subscription.customer) do
      %Organization{} = organization ->
        case organization.is_delinquent do
          true -> Organizations.update_organization(organization, %{billing_frequency: "none"})
          false -> nil
        end
      _ -> Logger.error "[WebhookController.process_subscription_deleted/1] No organization found with customer id: #{subscription.customer} for subscription: #{subscription.id}"
    end
  end

  defp process_card_update(event) do
    update = event.data.object

    case Payments.get_card_by_card_id(update.id) do
      %Card{} = card ->
        Card.update_expiration_date(card, %{
          exp_month: update.exp_month,
          exp_year: update.exp_year
        })
      _ -> Logger.error "[WebhookController.process_card_update/1] No card found with card id: #{update.id}"
    end
  end
end
