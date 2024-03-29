defmodule Mirror.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias Mirror.Repo

  alias Mirror.Teams
  alias Mirror.Teams.Team
  alias Mirror.Teams.MemberDelegate
  alias Mirror.Teams.Member
  alias Mirror.Teams.Admin

  alias Mirror.Helpers

  require Logger

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams do
    Repo.all(Team)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get_by!(Team, uuid: id)

  @doc """
  Gets a single team by subscription_id.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team_by_subscription_id!(sub_Dasdasdgasdasd)
      %Team{}

      iex> get_team_by_subscription_id!(sub_notfound)
      ** (Ecto.NoResultsError)

  """
  def get_team_by_subscription_id!(sub_id), do: Repo.get_by!(Team, subscription_id: sub_id)

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}, admins \\ [], members \\ [], delegates \\ []) do
    Repo.transaction fn ->
      with  {:ok, team}           <- Team.create(attrs),
            {:ok, updated_team}   <- Team.add_unique_id(team),
            [{:ok, _}]            <- Team.add_admins(team, admins),
            team_member_delegates <- Team.add_member_delegates(team, delegates),
            {:ok}                 <- MemberDelegate.send_invitations(team_member_delegates, team),
            [{:ok, _}]            <- Team.add_members(updated_team, members)
      do
        updated_team
        |> Team.preload_relationships()
      else
        {:error, changeset} ->
          Repo.rollback changeset
          {:error, changeset}
        _ ->
            {:error, :unknown}
      end
    end
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    Team.update(team, attrs)
  end

  @doc """
  Deletes a Team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """

  def delete_team(%Team{} = team) do
    Team.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{source: %Team{}}

  """
  def change_team(%Team{} = team) do
    Team.changeset(team, %{})
  end

  @doc """
  Returns the list of members.

  ## Examples

      iex> list_members()
      [%Member{}, ...]

  """
  def list_members do
    Repo.all(Member)
  end

  @doc """
  Gets a single member.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123)
      %Member{}

      iex> get_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member!(%{team_id: team_id, user_id: user_id}) do
    Repo.get_by!(Member, %{team_id: team_id, user_id: user_id})
  end

  @doc """
  Creates a member.

  ## Examples

      iex> create_member(%{field: value})
      {:ok, %Member{}}

      iex> create_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a member.

  ## Examples

      iex> update_member(member, %{field: new_value})
      {:ok, %Member{}}

      iex> update_member(member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Member.

  ## Examples

      iex> delete_member(member)
      {:ok, %Member{}}

      iex> delete_member(member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member(%Member{} = member) do
    member = member
    |> Member.preload_relationships

    team = member.team
    user = member.user

    cond do
        Helpers.User.user_is_team_admin?(user, team) ->
            with {:ok, _admin_affected_rows} <- Teams.delete_admin(%{user_id: user.id, team_id: team.id}),
                 {:ok, _member_affected_rows} <- Teams.delete_member(member)
            do
                {:ok, :removed}
            else
                {:error, :no_additional_admins} -> {:error, :no_additional_admins}
                {:error, changeset} -> Repo.rollback changeset
            end

        Helpers.User.user_is_team_member?(user, team) ->
            case Repo.delete_all(from u in Member, where: u.user_id == ^user.id and u.team_id == ^team.id) do
                {:error, _} -> {:error, nil}
                {affected_rows, _} -> {:ok, affected_rows}
            end
        true ->
            {:error, :unknown}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member changes.

  ## Examples

      iex> change_member(member)
      %Ecto.Changeset{source: %Member{}}

  """
  def change_member(%Member{} = member) do
    Member.changeset(member, %{})
  end

  @doc """
  Returns the list of admins.

  ## Examples

      iex> list_admins()
      [%Admin{}, ...]

  """
  def list_admins do
    Repo.all(Admin)
  end

  @doc """
  Gets a single admin.

  Raises `Ecto.NoResultsError` if the Admin does not exist.

  ## Examples

      iex> get_admin!(123)
      %Admin{}

      iex> get_admin!(456)
      ** (Ecto.NoResultsError)

  """
  def get_admin!(id), do: Repo.get!(Admin, id)

  @doc """
  Creates a admin.

  ## Examples

      iex> create_admin(%{team_id: value, user_id: value})
      {:ok, %Admin{}}

      iex> create_admin(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_admin(attrs \\ %{}) do
    %Admin{}
    |> Admin.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a Admin.

  ## Examples

      iex> delete_admin(admin)
      {:ok, %Admin{}}

      iex> delete_admin(admin)
      {:error, %Ecto.Changeset{}}

  """
  def delete_admin(attrs \\ %{}) do
    team = Repo.get!(Team, attrs.team_id)
    |> Team.preload_relationships

    cond do
        (length(team.admins) > 1) ->
            case Repo.delete_all(from u in Admin, where: u.user_id == ^attrs.user_id and u.team_id == ^attrs.team_id) do
                {:error, _} -> {:error, nil}
                {affected_rows, _} -> {:ok, affected_rows}
            end
        (length(team.admins) > 0) ->
            {:error, :no_additional_admins}
        true ->
            {:error, :unexpected}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking admin changes.

  ## Examples

      iex> change_admin(admin)
      %Ecto.Changeset{source: %Admin{}}

  """
  def change_admin(%Admin{} = admin) do
    Admin.changeset(admin, %{})
  end

  @doc """
  Returns the list of member_delegates.

  ## Examples

      iex> list_member_delegates()
      [%MemberDelegate{}, ...]

  """
  def list_member_delegates do
    Repo.all(MemberDelegate)
  end

  @doc """
  Gets a single member_delegate.

  Raises `Ecto.NoResultsError` if the Member delegate does not exist.

  ## Examples

      iex> get_member_delegate!(123)
      %MemberDelegate{}

      iex> get_member_delegate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member_delegate!(access_code), do: Repo.get_by!(MemberDelegate, access_code: access_code)

  @doc """
  Creates a member_delegate.

  ## Examples

      iex> create_member_delegate(%{field: value})
      {:ok, %MemberDelegate{}}

      iex> create_member_delegate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member_delegate(attrs \\ %{}) do
    %MemberDelegate{}
    |> MemberDelegate.changeset(attrs)
    |> Repo.insert()
  end

  def create_member_delegates(%Team{} = team, memeber_delegates \\ []) do
    Repo.transaction fn ->
        with  team_member_delegates <- Team.add_member_delegates(team, memeber_delegates),
              {:ok}                 <- MemberDelegate.send_invitations(team_member_delegates, team)
        do
          team_member_delegates
        else
          {:error, changeset} ->
            Repo.rollback changeset
            {:error, changeset}
          _ ->
              {:error, :unknown}
        end
      end
  end

  @doc """
  Updates a member_delegate.

  ## Examples

      iex> update_member_delegate(member_delegate, %{field: new_value})
      {:ok, %MemberDelegate{}}

      iex> update_member_delegate(member_delegate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member_delegate(%MemberDelegate{} = member_delegate, attrs) do
    member_delegate
    |> MemberDelegate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a MemberDelegate.

  ## Examples

      iex> delete_member_delegate(member_delegate)
      {:ok, %MemberDelegate{}}

      iex> delete_member_delegate(member_delegate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member_delegate(%MemberDelegate{} = member_delegate) do
    Repo.delete(member_delegate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member_delegate changes.

  ## Examples

      iex> change_member_delegate(member_delegate)
      %Ecto.Changeset{source: %MemberDelegate{}}

  """
  def change_member_delegate(%MemberDelegate{} = member_delegate) do
    MemberDelegate.changeset(member_delegate, %{})
  end
end
