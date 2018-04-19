defmodule Mirror.Organization do
  use Mirror.Web, :model

  require Logger

  alias Mirror.{Repo, Organization, OrganizationUser, OrganizationAdmin, HashHelper, Billing, Card}

  schema "organizations" do
    field :name, :string
    field :uuid, :string
    field :avatar, :string
    field :billing_customer, :string
    field :billing_status, :string, default: "inactive"
    field :billing_frequency, :string, default: "none"

    has_many :teams, Mirror.Team
    has_many :cards, Mirror.Card
    belongs_to :default_payment, Mirror.Card
    many_to_many :admins, Mirror.User, join_through: Mirror.OrganizationAdmin
    many_to_many :members, Mirror.User, join_through: Mirror.OrganizationUser

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :avatar, :uuid, :billing_customer, :billing_status, :default_payment_id, :billing_frequency])
    |> validate_required([:name, :avatar])
    |> validate_inclusion(:billing_frequency, ["none", "monthly", "yearly"])
  end

  def preload_relationships(organization) do
    organization
    |> Repo.preload([:members, :admins, :teams, :default_payment, :cards], force: true)
  end

  def get(id) do
    Repo.get_by!(Organization, uuid: id)
    |> Organization.preload_relationships()
  end

  def create(params) do
    Repo.transaction fn ->
      with {:ok, org} <- insert_organization(params),
           {:ok, updated_org} <- add_unique_id_to_organization(org),
           {:ok, billing_customer} <- create_billing_customer(updated_org),
           {:ok, org_with_billing} <- add_billing_to_organization(org, billing_customer),
           [{:ok, org_admins}] <- add_organization_admins(org, params.admins),
           [{:ok, org_members}] <- add_organization_members(org, params.members) do
             updated_org
             |> Organization.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
      end
    end
  end

  def update(organization, org_params, billing_params) do

    changeset = Organization.changeset(organization, org_params)
    case Repo.update(changeset) do
      {:ok, updated_organization} ->
        updated_organization = updated_organization
        |> Organization.preload_relationships()
        
        case billing_params do
          %{default_payment: default_payment} ->
            Billing.update_default_payment(updated_organization.billing_customer, billing_params.default_payment)
          _ ->
            nil
        end
        
        Billing.build_subscriptions(updated_organization)
        
        case update_billing_status(updated_organization) do
          {:ok, org_with_billing} -> 
            Logger.warn "#{inspect org_with_billing}"
            {:ok, org_with_billing}
          _ -> {:ok, updated_organization}
        end
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete(organization) do
    Billing.remove_subscriptions(organization);
    Repo.delete(organization)
  end

  def set_default_payment(organization) do
    organization = organization
    |> Organization.preload_relationships()

    case length(organization.cards) do
      0 -> {:error, "The organization has no cards on file."}
      1 -> {:ok, nil}
      _ ->
        default_options = Enum.filter(organization.cards, fn(card) ->
          !is_default_payment?(organization, card)
        end)
        set_default_payment(hd(default_options), organization)
    end
  end

  def set_default_payment(card, organization) do
    Repo.transaction fn ->
      with {:ok, updated_org}         <- insert_default_payment(card, organization),
           {:ok, status_updated_org}  <- update_billing_status(updated_org),
           {:ok, updated_cust}        <- Billing.update_default_payment(organization.billing_customer, card.card_id) do
             updated_org
             |> Organization.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
          {:error, changeset}
      end
    end
  end

  def update_billing_status(organization) do
    billing_status_changeset = case !is_nil(organization.default_payment_id) && (organization.billing_frequency != "none") do
      true -> Organization.changeset(organization, %{billing_status: "active"})
      false -> Organization.changeset(organization, %{billing_status: "inactive"})
    end

    case Repo.update(billing_status_changeset) do
      {:ok, updated_organization} -> {:ok, updated_organization}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def remove_default_payment(organization) do
    org_params = %{default_payment_id: nil}
    billing_params = %{}

    Organization.update(organization, org_params, billing_params)
  end

  def is_default_payment?(organization, card) do
    organization.default_payment_id == card.id
  end

  defp insert_default_payment(card, organization) do
    Organization.changeset(organization, %{default_payment_id: card.id})
    |> Repo.update
  end

  defp insert_organization(params) do
    %Organization{}
    |> Organization.changeset(%{name: params.attributes.name, isAnonymous: true, avatar: "default.png"})
    |> Repo.insert
  end

  defp add_unique_id_to_organization(organization) do
    organization_unique_id = HashHelper.generate_unique_id(organization.id, "org")

    organization
    |> Organization.changeset(%{uuid: organization_unique_id})
    |> Repo.update
  end

  defp create_billing_customer(organization) do
    new_customer = %{
      email: organization.uuid
    }

    Stripe.Customers.create new_customer
  end

  defp add_billing_to_organization(organization, billing_customer) do
    organization
    |> Organization.changeset(%{billing_customer: billing_customer.id})
    |> Repo.update
  end

  defp add_organization_members(organization, users) do
    cond do
      length(users) > 0 ->
        Enum.map users, fn user ->
          %OrganizationUser{}
          |> OrganizationUser.changeset(%{user_id: user.id, organization_id: organization.id})
          |> Repo.insert
        end
      true ->
        [{:ok, nil}]
    end
  end

  defp add_organization_admins(organization, admins) do
    cond do
      length(admins) > 0 ->
        Enum.map admins, fn admin ->
          %OrganizationAdmin{}
          |> OrganizationAdmin.changeset(%{user_id: admin.id, organization_id: organization.id})
          |> Repo.insert
        end
      true ->
        [{:ok, nil}]
    end
  end
end