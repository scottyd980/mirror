defmodule Mirror.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Mirror.Repo
  alias Mirror.Teams
  alias Mirror.Accounts.User
  alias Mirror.Teams.{Team, Admin, Member, MemberDelegate}
  alias Mirror.Retrospectives.Retrospective

  alias Mirror.Helpers.Hash
  #alias Mirror.Organizations.Organization

  schema "teams" do
    field :avatar, :string, default: "default.png"
    field :is_anonymous, :boolean, default: true
    field :name, :string
    field :uuid, :string
    # belongs_to :organization, Organization
    many_to_many :admins, User, join_through: Admin
    many_to_many :members, User, join_through: Member
    has_many :member_delegates, MemberDelegate
    has_many :retrospectives, Retrospective

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :avatar, :uuid, :is_anonymous])
    |> validate_required([:name])
  end

  def preload_relationships(team) do
    team
    # |> Repo.preload([:members, :admins, :organization], force: true)
  end

  def create(params) do
    %Team{}
    |> Team.changeset(%{name: params["name"]})
    |> Repo.insert
  end

  def add_unique_id(team) do
    team_unique_id = Hash.generate_unique_id(team.id, "team")

    team
    |> Team.changeset(%{uuid: team_unique_id})
    |> Repo.update
  end

  def add_members(team, users) do
    case length(users) > 0 do
      true ->
        Enum.map users, fn user ->
          Teams.create_member(%{user_id: user.id, team_id: team.id})
        end
      _ ->
        [{:ok, nil}]
    end
  end

  def add_member_delegates(team, delegates) do
    cond do
      length(delegates) > 0 ->
        Enum.map delegates, fn delegate ->
          Teams.create_member_delegate(%{email: delegate, team_id: team.id})
        end
      true ->
        []
    end
  end

  def add_admins(team, users) do
    case length(users) > 0 do
      true ->
        Enum.map users, fn user ->
          Teams.create_admin(%{user_id: user.id, team_id: team.id})
        end
      _ ->
        [{:ok, nil}]
    end
  end

  def find_last_retrospective(team) do
    retros = find_all_retrospectives(team)
    most_recent = Enum.filter(retros, fn(r) ->
      !r.cancelled
    end)
    |> Enum.sort(fn(d1, d2) ->
      NaiveDateTime.to_erl(d1.updated_at) > NaiveDateTime.to_erl(d2.updated_at)
    end)
    |> List.first
  end

  # def find_retrospective_in_progress(team) do
  #   retros = find_all_retrospectives(team)

  #   retro_in_progress = retros
  #   |> Enum.filter(fn(r) ->
  #     retro_type = Repo.get!(RetrospectiveType, r.type_id)
  #     r.state < retro_type.finished_state && !r.cancelled
  #   end)
    
  #   retro_in_progress
  # end

  def find_next_retrospective(team) do
    last_retro = find_last_retrospective(team)
    case last_retro do
      %Retrospective{} ->
        last_retro_number = last_retro.name
        |> String.split(" ")
        |> List.last
        |> String.to_integer

        last_retro_number + 1
      _ ->
        1
    end
  end

  def find_all_retrospectives(team) do
    Repo.all(from retro in Retrospective, where: retro.team_id == ^team.id)
  end
end
