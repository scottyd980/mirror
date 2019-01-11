defmodule Mirror.Payments.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mirror.Repo

  schema "stripe_events" do
    field :event_id, :string

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:event_id])
    |> validate_required([:event_id])
  end
end
