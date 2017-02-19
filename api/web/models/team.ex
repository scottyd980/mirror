defmodule Mirror.Team do
  use Mirror.Web, :model

  alias Mirror.{Repo, Retrospective, RetrospectiveType}

  schema "teams" do
    field :name, :string
    field :isAnonymous, :boolean, default: false
    field :avatar, :string
    field :uuid, :string
    many_to_many :admins, Mirror.User, join_through: Mirror.TeamAdmin
    many_to_many :members, Mirror.User, join_through: Mirror.UserTeam

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :isAnonymous, :avatar, :uuid])
    # |> cast_assoc(:admin)
    |> validate_required([:name, :isAnonymous, :avatar])
    # |> assoc_constraint(:admin)
  end

  def preload_relationships(team) do
    team
    |> Repo.preload([:members, :admins])
  end

  def check_retrospective_in_progress(team) do
    retro = get_retrospective_in_progress(team)

    retro_count = retro
    |> Enum.count

    in_progress = retro_count > 0

    {in_progress, retro}
  end

  def get_retrospective_in_progress(team) do
    retros = get_all_retrospectives(team)

    retro_in_progress = retros
    |> Enum.filter(fn(r) ->
      retro_type = Repo.get!(RetrospectiveType, r.type_id)
      r.state < retro_type.finished_state && !r.cancelled
    end)
    
    retro_in_progress
  end

  def get_most_recent_retrospective(team) do
    retros = get_all_retrospectives(team)
    most_recent = Enum.filter(retros, fn(r) ->
      !r.cancelled
    end)
    |> Enum.sort(fn(d1, d2) ->
      Ecto.DateTime.to_erl(d1.updated_at) > Ecto.DateTime.to_erl(d2.updated_at)
    end)
    |> List.first
  end

  def get_next_retrospective(team) do
    current_retro = get_most_recent_retrospective(team)
    current_retro_number = current_retro.name
    |> String.split(" ")
    |> List.last
    |> String.to_integer

    current_retro_number + 1
  end

  def get_all_retrospectives(team) do
    Repo.all(from retro in Retrospective, where: retro.team_id == ^team.id)
  end
end
