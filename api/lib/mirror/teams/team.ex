defmodule Mirror.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Mirror.Repo
  alias Mirror.Teams
  alias Mirror.Accounts.User
  alias Mirror.Teams.{Team, Admin, Member, MemberDelegate}
  alias Mirror.Retrospectives.{Retrospective, Game}
  alias Mirror.Organizations.Organization

  alias Mirror.Payments.{Billing, BillingNew}

  alias Mirror.Helpers.{Hash, Trial}

  @trial_period 2678400

  schema "teams" do
    field :avatar, :string, default: "default.png"
    field :is_anonymous, :boolean, default: true
    field :name, :string
    field :uuid, :string
    field :trial_end, :integer
    field :period_end, :integer
    belongs_to :organization, Organization
    many_to_many :admins, User, join_through: Admin
    many_to_many :members, User, join_through: Member
    has_many :member_delegates, MemberDelegate
    has_many :retrospectives, Retrospective

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :avatar, :uuid, :is_anonymous, :organization_id])
    |> validate_required([:name])
  end

  def create_changeset(team, attrs) do
    period_end = Trial.create_end_date()

    team
    |> cast(attrs, [:name, :avatar, :uuid, :is_anonymous, :organization_id])
    |> validate_required([:name])
    |> put_change(:trial_end, period_end)
    |> put_change(:period_end, period_end)
  end

  def billing_changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :avatar, :uuid, :is_anonymous, :organization_id])
    |> validate_required([:name])
  end

  def webhook_changeset(team, attrs) do
    team
    |> cast(attrs, [:period_end])
  end

  def preload_relationships(team) do
    team
    |> Repo.preload([:members, :admins, :retrospectives, :organization], force: true)
  end

  def create(attrs) do
    %Team{}
    |> Team.create_changeset(%{name: attrs["name"]})
    |> Repo.insert
  end

  # Stripe / with do end
  def update(%Team{} = team, attrs) do
    original_team = team
    |> Team.preload_relationships()

    resp = team
    |> Team.changeset(attrs)
    |> Repo.update()

    {:ok, team} = resp

    team = team
    |> Team.preload_relationships

    # case team.organization do
    #   nil -> Billing.tear_down_subscriptions(original_team.organization)
    #   organization ->
    #     {:ok, _} = Billing.setup_subscriptions(organization)
    # end

    case team.organization do
      nil ->
        {:ok, _} = BillingNew.process_subscription(original_team.organization)
      organization ->
        {:ok, _} = BillingNew.process_subscription(organization)
    end

    resp
  end

  def update_subscription_period(%Team{} = team, attrs) do
    team
    |> Team.webhook_changeset(attrs)
    |> Repo.update()
  end

  def delete(%Team{} = team) do
    team = team
    |> Team.preload_relationships()

    current_org = team.organization

    Repo.transaction fn ->
        with {:ok, team}  <- Repo.delete(team),
             removed_sub  <- Billing.tear_down_subscriptions(current_org)
        do
            team
        else
            {:error, changeset} ->
                Repo.rollback changeset
                {:error, changeset}
        end
    end
  end

  def add_unique_id(team) do
    team_unique_id = Hash.generate_unique_id(team.id, "team")

    team
    |> Team.changeset(%{uuid: team_unique_id})
    |> Repo.update
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

  def find_last_retrospective(team) do
    retros = find_all_retrospectives(team)
    Enum.filter(retros, fn(r) ->
      !r.cancelled
    end)
    |> Enum.sort(fn(d1, d2) ->
      NaiveDateTime.to_erl(d1.updated_at) > NaiveDateTime.to_erl(d2.updated_at)
    end)
    |> List.first
  end

  def find_retrospective_in_progress(team) do
    retros = find_all_retrospectives(team)

    retro_in_progress = retros
    |> Enum.filter(fn(r) ->
      retro_type = Repo.get!(Game, r.game_id)
      r.state < retro_type.finished_state && !r.cancelled
    end)

    retro_in_progress
  end

  def check_retrospective_in_progress(team) do
    retro = find_retrospective_in_progress(team)

    retro_count = retro
    |> Enum.count

    in_progress = retro_count > 0

    {in_progress, retro}
  end

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

  #TODO: find uses of these
  def in_trial_period?(team) do
    now = Timex.Duration.now(:seconds)
    trial_end = Team.get_trial_period_end(team)

    {(now - 60) < trial_end, trial_end}
  end

  def get_trial_period_end(team) do
    created_at = team.inserted_at |> NaiveDateTime.to_erl |> :calendar.datetime_to_gregorian_seconds |> Kernel.-(62167219200)
    created_at + @trial_period
  end
end
