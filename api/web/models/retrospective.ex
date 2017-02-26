defmodule Mirror.Retrospective do
  use Mirror.Web, :model

  alias Mirror.{Repo, Retrospective, RetrospectiveType, RetrospectiveUser, User, Feedback, SprintScore, Team}

  import Logger

  schema "retrospectives" do
    field :name, :string
    field :state, :integer, default: 0
    field :isAnonymous, :boolean, default: true
    field :cancelled, :boolean, default: false
    has_many :scores, SprintScore, on_delete: :delete_all
    has_many :feedbacks, Feedback, on_delete: :delete_all
    belongs_to :team, Team
    belongs_to :moderator, User
    belongs_to :type, RetrospectiveType
    many_to_many :participants, User, join_through: RetrospectiveUser, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :state, :isAnonymous, :cancelled, :team_id, :moderator_id, :type_id])
    |> validate_required([:name, :state, :isAnonymous, :team_id, :moderator_id, :type_id])
  end

  def preload_relationships(retrospective) do
    retrospective
    |> Repo.preload([:team, :moderator, :participants, :scores, :feedbacks, :type])
  end

  def create(params) do
    Repo.transaction fn ->
      with {:ok, retrospective} <- insert_retrospective(params),
           [{:ok, retrospective_participants}] <- add_retrospective_participants(retrospective, params["participants"]) do
             retrospective
             |> Retrospective.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
      end
    end
  end

  defp insert_retrospective(params) do
    %Retrospective{}
    |> Retrospective.changeset(%{
        name: params["attributes"]["name"],
        isAnonymous: params["attributes"]["is-anonymous"],
        state: params["attributes"]["state"],
        moderator_id: params["moderator"]["data"]["id"],
        team_id: params["team"].id,
        type_id: params["attributes"]["type"]
      })
    |> Repo.insert
  end

  defp add_retrospective_participants(retrospective, participants) do
    cond do
      length(participants["data"]) > 0 ->
        Enum.map participants["data"], fn participant ->
          %RetrospectiveUser{}
          |> RetrospectiveUser.changeset(%{user_id: participant.id, retrospective_id: retrospective.id})
          |> Repo.insert
        end
      true ->
        [{:ok, nil}]
    end
  end
end
