defmodule Mirror.RetrospectiveType do
  use Mirror.Web, :model

  schema "retrospective_types" do
    field :name, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
