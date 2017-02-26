defmodule Mirror.User do
  use Mirror.Web, :model

  alias Mirror.Repo

  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string

    # Two virtual fields for password confirmation
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    # Relationships
    has_many :scores, Mirror.SprintScore
    many_to_many :teams, Mirror.Team, join_through: Mirror.UserTeam
    many_to_many :organizations, Mirror.Organization, join_through: Mirror.OrganizationUser

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password, :password_confirmation])
    |> validate_required([:username, :email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> hash_password()
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  def preload_relationships(user) do
    user
    |> Repo.preload([:scores, :teams, :organizations])
  end

  defp hash_password(%{valid?: false} = changeset), do: changeset
  defp hash_password(%{valid?: true} = changeset) do
      hashedpw = Comeonin.Bcrypt.hashpwsalt(Ecto.Changeset.get_field(changeset, :password))
      Ecto.Changeset.put_change(changeset, :password_hash, hashedpw)
  end
end
