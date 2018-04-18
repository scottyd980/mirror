defmodule Mirror.Teams.MemberDelegate do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mirror.Teams.Team
  alias Mirror.Helpers.Hash

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

  defp create_access_code(%{valid?: false} = changeset), do: changeset
  defp create_access_code(%{valid?: true} = changeset) do
      access_code = Hash.generate_unique_id(Ecto.Changeset.get_field(changeset, :team_id), Ecto.Changeset.get_field(changeset, :email))
      Ecto.Changeset.put_change(changeset, :access_code, access_code)
  end
end
