defmodule Mirror.Organization do
  use Mirror.Web, :model

  alias Mirror.{Repo, Organization, OrganizationUser, OrganizationAdmin, HashHelper}

  schema "organizations" do
    field :name, :string
    field :uuid, :string
    field :avatar, :string
    field :billing_customer, :string

    has_many :teams, Mirror.Team, on_delete: :delete_all
    has_many :cards, Mirror.Card, on_delete: :delete_all
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
    |> cast(params, [:name, :avatar, :uuid, :billing_customer, :default_payment_id])
    |> validate_required([:name, :avatar])
  end

  def preload_relationships(organization) do
    organization
    |> Repo.preload([:members, :admins, :teams, :default_payment, :cards], force: true)
  end

  def create(params) do
    Repo.transaction fn ->
      with {:ok, org} <- insert_organization(params),
           {:ok, updated_org} <- add_unique_id_to_organization(org),
           {:ok, billing_customer} <- create_billing_customer(updated_org),
           {:ok, org_with_billing} <- add_billing_to_organization(org, billing_customer),
           [{:ok, org_admins}] <- add_organization_admins(org, params["admins"]),
           [{:ok, org_members}] <- add_organization_members(org, params["members"]) do
             updated_org
             |> Organization.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
      end
    end
  end

  defp insert_organization(params) do
    %Organization{}
    |> Organization.changeset(%{name: params["attributes"]["name"], isAnonymous: true, avatar: "default.png"})
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
