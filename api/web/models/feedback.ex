defmodule Mirror.Feedback do
  use Mirror.Web, :model

  alias Mirror.Repo
  alias Mirror.Retrospective
  alias Mirror.User
  alias Mirror.UserHelper

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
    |> validate_retrospective_member
    |> validate_feedback_not_submitted
  end

  def moderator_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> validate_moderator
  end

  def preload_relationships(feedback) do
    feedback
    |> Repo.preload([:user, :retrospective])
  end

  defp validate_retrospective_member(changeset) do
    user_id = get_field(changeset, :user_id)
    retrospective_id = get_field(changeset, :retrospective_id)

    current_user = Repo.get!(User, user_id)
    retrospective = Repo.get!(Retrospective, retrospective_id)

    cond do
      UserHelper.user_is_participant?(current_user, retrospective) ->
        changeset
      true ->
        changeset
        |> add_error(:retrospective_id, "Unknown retrospective.")
    end
  end

  # TODO: complete
  defp validate_feedback_not_submitted(changeset) do
    changeset
  end

  defp validate_moderator(changeset) do
    changeset
  end
end
