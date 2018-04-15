defmodule Mirror.Action do
    use Mirror.Web, :model
  
    alias Mirror.{Repo, Feedback, User, UserHelper}
  
    schema "actions" do
      field :message, :string
      belongs_to :feedback, Feedback
  
      timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:message, :feedback_id])
        |> validate_required([:message, :feedback_id])
    end

    def preload_relationships(action) do
        action
        |> Repo.preload([:feedback], force: true)
    end
end