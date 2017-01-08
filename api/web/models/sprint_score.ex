defmodule Mirror.SprintScore do
  use Mirror.Web, :model

  schema "sprint_scores" do
    field :score, :integer
    belongs_to :user, Mirror.User
    belongs_to :retrospective, Mirror.Retrospective

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:score, :user_id, :retrospective_id])
    |> validate_required([:score, :user_id, :retrospective_id])
  end
end
