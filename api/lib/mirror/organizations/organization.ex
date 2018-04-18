defmodule Mirror.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mirror.Teams.Team
  alias Mirror.Accounts.User
  alias Mirror.Organizations.Admin
  alias Mirror.Organizations.Member

  schema "organizations" do
    field :avatar, :string
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
    |> validate_required([:name, :uuid, :avatar])
  end
end
