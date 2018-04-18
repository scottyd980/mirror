defmodule Mirror.Retrospectives do
  @moduledoc """
  The Retrospectives context.
  """

  import Ecto.Query, warn: false
  alias Mirror.Repo

  alias Mirror.Retrospectives.Retrospective

  @doc """
  Returns the list of retrospectives for the given team.

  ## Examples

      iex> list_retrospectives(team)
      [%Retrospective{}, ...]

  """
  def list_retrospectives(team) do
    query = from r in Retrospective,
            where: r.team_id == ^team.id,
            where: r.cancelled == false
    
    Repo.all(query)
    |> Retrospective.preload_relationships()
  end

  @doc """
  Gets a single retrospective.

  Raises `Ecto.NoResultsError` if the Retrospective does not exist.

  ## Examples

      iex> get_retrospective!(123)
      %Retrospective{}

      iex> get_retrospective!(456)
      ** (Ecto.NoResultsError)

  """
  def get_retrospective!(id), do: Repo.get!(Retrospective, id)

  @doc """
  Creates a retrospective.

  ## Examples

      iex> create_retrospective(%{field: value})
      {:ok, %Retrospective{}}

      iex> create_retrospective(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_retrospective(attrs \\ %{}) do
    %Retrospective{}
    |> Retrospective.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a retrospective.

  ## Examples

      iex> update_retrospective(retrospective, %{field: new_value})
      {:ok, %Retrospective{}}

      iex> update_retrospective(retrospective, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_retrospective(%Retrospective{} = retrospective, attrs) do
    retrospective
    |> Retrospective.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Retrospective.

  ## Examples

      iex> delete_retrospective(retrospective)
      {:ok, %Retrospective{}}

      iex> delete_retrospective(retrospective)
      {:error, %Ecto.Changeset{}}

  """
  def delete_retrospective(%Retrospective{} = retrospective) do
    Repo.delete(retrospective)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking retrospective changes.

  ## Examples

      iex> change_retrospective(retrospective)
      %Ecto.Changeset{source: %Retrospective{}}

  """
  def change_retrospective(%Retrospective{} = retrospective) do
    Retrospective.changeset(retrospective, %{})
  end
end
