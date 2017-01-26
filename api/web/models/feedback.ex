defmodule Mirror.Feedback do
  use Mirror.Web, :model

  alias Mirror.Repo

  schema "feedbacks" do
    field :type, :string
    field :message, :string
    field :state, :integer
    belongs_to :user, Mirror.User
    belongs_to :retrospective, Mirror.Retrospective

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :message, :state, :user_id, :retrospective_id])
    |> validate_required([:type, :message, :state, :user_id, :retrospective_id])
  end

  def preload_relationships(feedback) do
    feedback
    |> Repo.preload([:user, :retrospective])
  end
end
