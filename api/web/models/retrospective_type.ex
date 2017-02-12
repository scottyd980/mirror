defmodule Mirror.RetrospectiveType do
  use Mirror.Web, :model

  schema "retrospective_types" do
    field :name, :string
    field :finished_state, :integer

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :finished_state])
    |> validate_required([:name, :finished_state])
  end
end
