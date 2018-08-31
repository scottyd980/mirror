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

  alias Mirror.Helpers.Hash

  schema "organizations" do
    field :avatar, :string, default: "default.png"
    field :name, :string
    field :uuid, :string
    field :billing_customer, :string
    field :billing_status, :string, default: "inactive"
    field :billing_frequency, :string, default: "none"

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

  def preload_relationships(organization) do
    organization
    |> Repo.preload([:teams, :admins, :members, :default_payment, :cards], force: true)
  end
  
  def create(attrs) do
    %Organization{}
    |> Organization.changeset(%{name: attrs["name"]})
    |> Repo.insert
  end

  # TODO: Stripe / with do end
  def update(%Organization{} = organization, attrs) do
    resp = organization
    |> Organization.changeset(attrs)
    |> Repo.update()

    {:ok, org} = resp

    org = org
    |> Organization.preload_relationships()

    {:ok, _} = Billing.set_default_payment(organization)
    {:ok, _} = Billing.setup_subscriptions(organization)

    resp
  end

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

    Organization.update(org, %{billing_status: status})
  end
end
