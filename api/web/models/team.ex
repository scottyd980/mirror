defmodule Mirror.Team do
  use Mirror.Web, :model

  alias Mirror.{Repo, Retrospective, RetrospectiveType}

  import Logger

  schema "teams" do
    field :name, :string
    field :isAnonymous, :boolean, default: false
    field :avatar, :string
    field :uuid, :string
    belongs_to :organization, Mirror.Organization
    many_to_many :admins, Mirror.User, join_through: Mirror.TeamAdmin
    many_to_many :members, Mirror.User, join_through: Mirror.UserTeam

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :isAnonymous, :avatar, :uuid, :organization_id])
    # |> cast_assoc(:admin)
    |> validate_required([:name, :isAnonymous, :avatar])
    # |> assoc_constraint(:admin)
  end

  def preload_relationships(team) do
    team
    |> Repo.preload([:members, :admins, :organization])
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
    case current_retro do
      %Retrospective{} ->
        current_retro_number = current_retro.name
        |> String.split(" ")
        |> List.last
        |> String.to_integer

        current_retro_number + 1
      _ ->
        1
    end
  end

  def get_all_retrospectives(team) do
    Repo.all(from retro in Retrospective, where: retro.team_id == ^team.id)
  end

  def verify_billing(team) do
    retrospectives = get_all_retrospectives(team)

    retro_count = retrospectives
    |> Enum.count

    case get_remaining_trial_period(team) > 0 do
      true ->
        true
      _ ->
        # TODO: This will need to be updated for billing
        false
    end
  end

  def get_remaining_trial_period(team) do
    now = Timex.Duration.now(:seconds) |> DateTime.from_unix!
    created_at = team.inserted_at |> Ecto.DateTime.to_erl |> :calendar.datetime_to_gregorian_seconds |> Kernel.-(62167219200) |> DateTime.from_unix!
    days_old = Timex.diff(created_at, now, :days)
    remaining_days = 30 + days_old
    Logger.warn "Remaining days in trial period: #{remaining_days}"
    remaining_days
  end
end
