defmodule Mirror.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Mirror.Repo

  alias Mirror.Teams.Team
  alias Mirror.Accounts.User
  alias Mirror.Organizations
  alias Mirror.Organizations.{Organization, Admin, Member}

  alias Mirror.Payments
  alias Mirror.Payments.Card
  alias Mirror.Payments.Billing
  alias Mirror.Payments.BillingNew

  alias Mirror.Helpers.{Hash, Trial}

  require Logger

  schema "organizations" do
    field :avatar, :string, default: "default.png"
    field :name, :string
    field :uuid, :string
    field :billing_customer, :string
    field :billing_status, :string, default: "inactive"
    field :billing_frequency, :string, default: "none"
    field :trial_end, :integer
    field :period_end, :integer

    has_many :teams, Team
    has_many :cards, Card
    belongs_to :default_payment, Card
    many_to_many :admins, User, join_through: Admin
    many_to_many :members, User, join_through: Member

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :avatar, :uuid, :billing_customer, :billing_status, :default_payment_id, :billing_frequency])
    |> validate_required([:name, :avatar])
    |> validate_inclusion(:billing_frequency, ["none", "monthly", "yearly"])
  end

  # Changesets
  def create_changeset(organization, attrs) do
    period_end = Trial.create_end_date()

    organization
    |> changeset(attrs)
    |> put_change(:trial_end, period_end)
    |> put_change(:period_end, period_end)
  end

  def update_changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :default_payment_id, :billing_frequency])
    |> validate_inclusion(:billing_frequency, ["none", "monthly", "yearly"])
  end

  def webhook_changeset(organization, attrs) do
    organization
    |> cast(attrs, [:period_end])
  end

  def billing_changeset(organization, attrs) do
    organization
    |> cast(attrs, [:billing_status, :billing_frequency, :default_payment_id])
    |> validate_inclusion(:billing_status, ["active", "inactive"])
  end
  # End Changesets

  # Preload helper
  def preload_relationships(organization) do
    organization
    |> Repo.preload([:teams, :admins, :members, :default_payment, :cards], force: true)
  end
  # End Preload helper

  # Organization Creation Helpers
  def add_unique_id(organization) do
    organization_unique_id = Hash.generate_unique_id(organization.id, "organization")

    organization
    |> Organization.changeset(%{uuid: organization_unique_id})
    |> Repo.update
  end

  def add_billing_customer(organization) do
    new_customer = %{
      email: organization.uuid
    }

    {:ok, billing_customer} = Stripe.Customer.create new_customer

    organization
    |> Organization.changeset(%{billing_customer: billing_customer.id})
    |> Repo.update
  end

  def add_admins(organization, users) do
    case length(users) > 0 do
      true ->
        Enum.map users, fn user ->
          Organizations.create_admin(%{user_id: user.id, organization_id: organization.id})
        end
      _ ->
        [{:ok, nil}]
    end
  end

  def add_members(organization, users) do
    case length(users) > 0 do
      true ->
        Enum.map users, fn user ->
          Organizations.create_member(%{user_id: user.id, organization_id: organization.id})
        end
      _ ->
        [{:ok, nil}]
    end
  end
  # End Organization Creation Helpers

  # Basic Interfaces
  def create(attrs) do
    %Organization{}
    |> Organization.create_changeset(%{name: attrs["name"]})
    |> Repo.insert
  end

  def update(%Organization{} = organization, attrs) do
    resp = organization
    |> Organization.update_changeset(attrs)
    |> Repo.update()

    resp
  end
  # End Basic Interfaces

  # Payment Processor Interfaces
  def update_payment_source(organization, card_status \\ :modified) do
    case card_status do
      :modified -> BillingNew.set_default_source(organization)
      _ -> {:ok, :unmodified}
    end
  end

  def update_subscription_period(organization, attrs) do
    organization
    |> Organization.webhook_changeset(attrs)
    |> Repo.update()
  end

  # TODO: Stripe / with do end?
  def process_subscription(organization, frequency_updated \\ false) do
    case organization.billing_status do
      "active" -> BillingNew.process_subscription(organization, frequency_updated)
      # TODO: Update to handle frequency to trial ("inactive")
      _ -> {:ok, nil}
    end
  end
  # End Payment Processor Interfaces

  def set_default_payment(card, default) do
    card = card
    |> Card.preload_relationships

    organization = card.organization

    case default do
      true -> Organization.update(organization, %{default_payment_id: card.id})
      _ -> {:ok, organization}
    end
  end

  def remove_default_payment(organization) do
    organization
    |> Organization.changeset(%{default_payment_id: nil})
    |> Repo.update
  end

  # TODO: Make sure everything here calls the right things at the right time (or even gets called itself)
  # Currently deleting a card that is the default and not the only one on the account errors.
  # Also consider making sure the card isn't expired
  def set_alternate_default_payment(card) do
    card = card
    |> Card.preload_relationships()

    organization = card.organization
    |> Organization.preload_relationships()

    available_cards = Enum.filter(organization.cards, fn(new_card) ->
      new_card.id != card.id
    end)

    case length(available_cards) do
      0 -> Organization.remove_default_payment(organization)
      _ -> Organization.update(organization, %{default_payment_id: hd(available_cards)})
    end
  end

  # TODO: Handle stripe subscription or call billing service to handle
  def set_billing_status(organization) do
    {:ok, status} = get_billing_status(organization)

    result = organization
    |> Organization.billing_changeset(%{billing_status: status})
    |> Repo.update()

    BillingNew.process_subscription(organization)

    result
  end

  def get_billing_status(organization) do
    org = organization
    |> Organization.preload_relationships

    card = case organization.default_payment_id do
      nil -> nil
      _ -> Payments.get_card!(organization.default_payment_id)
    end

    frequency = org.billing_frequency

    status = case frequency do
      "none" -> "inactive"
      _ ->
        case Card.get_status(card) do
          :valid -> "active"
          # TODO: Might return something else here describing why inactive
          _ -> "inactive"
        end
    end

    {:ok, status}
  end
end
