defmodule Mirror.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias Mirror.Repo

  alias Mirror.Teams.Team
  alias Mirror.Teams.MemberDelegate
  alias Mirror.Teams.Member
  alias Mirror.Teams.Admin

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
            [{:ok, team_admins}]  <- Team.add_admins(team, admins),
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
    team
    |> Team.changeset(attrs)
    |> Repo.update()
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
    Repo.delete(team)
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
  def get_member!(id), do: Repo.get!(Member, id)

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
    Repo.delete(member)
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

      iex> create_admin(%{field: value})
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
  Updates a admin.

  ## Examples

      iex> update_admin(admin, %{field: new_value})
      {:ok, %Admin{}}

      iex> update_admin(admin, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_admin(%Admin{} = admin, attrs) do
    admin
    |> Admin.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Admin.

  ## Examples

      iex> delete_admin(admin)
      {:ok, %Admin{}}

      iex> delete_admin(admin)
      {:error, %Ecto.Changeset{}}

  """
  def delete_admin(%Admin{} = admin) do
    Repo.delete(admin)
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
  def get_member_delegate!(id), do: Repo.get!(MemberDelegate, id)

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
