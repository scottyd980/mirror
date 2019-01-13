defmodule Mirror.Retrospectives.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "retrospective_games" do
    field :finished_state, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:name, :finished_state])
    |> validate_required([:name, :finished_state])
  end
end
