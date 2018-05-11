defmodule Mirror.Teams.MemberDelegate do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mirror.Repo

  alias Mirror.Teams.Team

  alias Mirror.Helpers.Hash
  alias Mirror.Email
  alias Mirror.Mailer

  schema "team_member_delegates" do
    field :access_code, :string
    field :email, :string
    field :is_accessed, :boolean, default: false

    belongs_to :team, Team

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :access_code, :is_accessed, :team_id])
    |> validate_required([:email, :is_accessed, :team_id])
    |> validate_format(:email, ~r/@/, message: "is invalid")
    |> create_access_code()
  end

  def preload_relationships(member_delegate) do
    member_delegate
    |> Repo.preload([:team], force: true)
  end

  defp create_access_code(%{valid?: false} = changeset), do: changeset
  defp create_access_code(%{valid?: true} = changeset) do
      access_code = Hash.generate_unique_id(Ecto.Changeset.get_field(changeset, :team_id), Ecto.Changeset.get_field(changeset, :email))
      Ecto.Changeset.put_change(changeset, :access_code, access_code)
  end

  def send_invitations(delegates, team) do
    Enum.each(delegates, fn {:ok, delegate} ->
      Email.invitation_email(delegate.email, delegate.access_code, team.name) 
      |> Mailer.deliver_later
    end)
    {:ok}
  end
end
