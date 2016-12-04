defmodule Mirror.RetrospectiveUser do
  use Mirror.Web, :model

  @primary_key false
  schema "retrospective_participants" do
    belongs_to :user, Mirror.User
    belongs_to :retrospective, Mirror.Retrospective

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :retrospective_id])
    |> validate_required([:user_id, :retrospective_id])
  end
end
