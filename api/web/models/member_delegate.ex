defmodule Mirror.MemberDelegate do
  use Mirror.Web, :model

  @hashconfig Hashids.new([
    salt: "?d[]?a5$~<).hU%L}0k-krUz>^[xJ@Y(yAna%`-k4Hs{^=5T6@/k]PFqkJ;FlbV+",  # using a custom salt helps producing unique cipher text
    min_len: 6,   # minimum length of the cipher text (1 by default)
  ])

  schema "member_delegate" do
    field :email, :string
    field :access_code, :string
    field :is_accessed, :boolean, default: false

    belongs_to :team, Mirror.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :access_code, :is_accessed, :team_id])
    |> validate_required([:email, :is_accessed, :team_id])
    |> validate_format(:email, ~r/@/)
    |> create_access_code()
  end

  defp create_access_code(%{valid?: false} = changeset), do: changeset
  defp create_access_code(%{valid?: true} = changeset) do
      access_code = generate_access_code(Ecto.Changeset.get_field(changeset, :team_id), Ecto.Changeset.get_field(changeset, :email))
      Ecto.Changeset.put_change(changeset, :access_code, access_code)
  end

  defp generate_access_code(team_id, email) do
    email_chars = String.to_char_list(email)
    Hashids.encode(@hashconfig, [team_id | email_chars])
  end
end
