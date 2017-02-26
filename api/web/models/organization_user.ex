defmodule Mirror.OrganizationUser do
  use Mirror.Web, :model

  @primary_key false
  schema "organization_user" do
    belongs_to :user, Mirror.User
    belongs_to :organization, Mirror.Organization

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :organization_id])
    |> validate_required([:user_id, :organization_id])
  end
end