defmodule Mirror.Organization do
  use Mirror.Web, :model

  alias Mirror.{Repo}

  schema "organizations" do
    field :name, :string
    field :uuid, :string
    field :avatar, :string

    many_to_many :admins, Mirror.User, join_through: Mirror.OrganizationAdmin
    many_to_many :members, Mirror.User, join_through: Mirror.OrganizationUser

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :uuid])
    |> validate_required([:name])
  end

  def preload_relationships(organization) do
    organization
    |> Repo.preload([:members, :admins])
  end
end
