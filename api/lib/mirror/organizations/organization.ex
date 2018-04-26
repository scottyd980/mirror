defmodule Mirror.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Mirror.Repo

  alias Mirror.Teams.Team
  alias Mirror.Accounts.User
  alias Mirror.Organizations
  alias Mirror.Organizations.{Organization, Admin, Member}

  alias Mirror.Helpers.Hash

  schema "organizations" do
    field :avatar, :string, default: "default.png"
    field :name, :string
    field :uuid, :string

    has_many :teams, Team
    many_to_many :admins, User, join_through: Admin
    many_to_many :members, User, join_through: Member

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :uuid, :avatar])
    |> validate_required([:name])
  end

  def preload_relationships(organization) do
    organization
    |> Repo.preload([:teams, :admins, :members], force: true)
  end
  
  def create(attrs) do
    %Organization{}
    |> Organization.changeset(%{name: attrs["name"]})
    |> Repo.insert
  end

  def add_unique_id(organization) do
    organization_unique_id = Hash.generate_unique_id(organization.id, "organization")

    organization
    |> Organization.changeset(%{uuid: organization_unique_id})
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
end
