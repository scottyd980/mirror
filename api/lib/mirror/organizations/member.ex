defmodule Mirror.Organizations.Member do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mirror.Organizations.Organization
  alias Mirror.Accounts.User

  @primary_key false
  schema "organization_members" do
    belongs_to :user, User
    belongs_to :organization, Organization

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :organization_id])
    |> validate_required([:user_id, :organization_id])
  end
end
