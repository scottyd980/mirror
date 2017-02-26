defmodule Mirror.Organization do
  use Mirror.Web, :model

  schema "organizations" do
    field :name, :string
    field :uuid, :string

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
end
