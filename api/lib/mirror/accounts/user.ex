defmodule Mirror.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mirror.Repo

  import Comeonin.Bcrypt

  alias Mirror.Accounts
  alias Mirror.Teams
  alias Mirror.Teams.Team
  alias Mirror.Organizations
  alias Mirror.Organizations.Organization

  alias Mirror.Helpers.Hash

  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string
    field :display_name, :string
    field :reset_password_token, :string
    field :reset_token_sent_at, :integer

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    many_to_many :teams, Team, join_through: Teams.Member
    many_to_many :organizations, Organization, join_through: Organizations.Member

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :password_confirmation])
    |> validate_required([:username, :email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/, message: "is invalid")
    |> validate_length(:password, min: 6, message: "should be at least %{count} characters")
    |> validate_confirmation(:password, message: "does not match password")
    |> hash_password()
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  def password_recovery_changeset(user) do
    uuid = Hash.generate_unique_id
    time = DateTime.to_unix(DateTime.utc_now())

    attrs = %{
      reset_password_token: uuid,
      reset_token_sent_at: time
    }

    user
    |> cast(attrs, [:reset_password_token, :reset_token_sent_at])
  end

  def password_reset_changeset(user, attrs) do
    attrs = Map.put(attrs, :reset_password_token, nil)
    attrs = Map.put(attrs, :reset_token_sent_at, nil)

    user
    |> cast(attrs, [:password, :password_confirmation, :reset_password_token, :reset_token_sent_at])
    |> validate_length(:password, min: 6, message: "should be at least %{count} characters")
    |> validate_confirmation(:password, message: "does not match password")
    |> hash_password()
  end

  def preload_relationships(user) do
    user
    |> Repo.preload([:teams, :organizations], force: true)
  end

  def login(username, password) do
    try do
      user = Accounts.find_user!(username)
      # Attempt to retrieve exactly one user from the DB, whose
      # email matches the one provided with the login request
      cond do
        checkpw(password, user.password_hash) ->
          {:ok, jwt, _} = Mirror.Guardian.encode_and_sign(user)
          {:ok, jwt, "LOGIN - SUCCESS: #{username}"}
        true ->
          {:error, "LOGIN - FAILURE: #{username}"}
      end
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging
        {:error, "LOGIN - UNEXPECTED ERROR: #{username}"}
    end
  end

  defp hash_password(%{valid?: false} = changeset), do: changeset
  defp hash_password(%{valid?: true} = changeset) do
      hashedpw = Comeonin.Bcrypt.hashpwsalt(Ecto.Changeset.get_field(changeset, :password))
      Ecto.Changeset.put_change(changeset, :password_hash, hashedpw)
  end
end
