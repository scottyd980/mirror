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

  alias Mirror.Retrospectives.Participant

  @doc """
  Returns the list of participants.

  ## Examples

      iex> list_participants()
      [%Participant{}, ...]

  """
  def list_participants do
    Repo.all(Participant)
  end

  @doc """
  Gets a single participant.

  Raises `Ecto.NoResultsError` if the Participant does not exist.

  ## Examples

      iex> get_participant!(123)
      %Participant{}

      iex> get_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_participant!(id), do: Repo.get!(Participant, id)

  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Participant.

  ## Examples

      iex> delete_participant(participant)
      {:ok, %Participant{}}

      iex> delete_participant(participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_participant(%Participant{} = participant) do
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant changes.

  ## Examples

      iex> change_participant(participant)
      %Ecto.Changeset{source: %Participant{}}

  """
  def change_participant(%Participant{} = participant) do
    Participant.changeset(participant, %{})
  end

  alias Mirror.Retrospectives.Score

  @doc """
  Returns the list of scores.

  ## Examples

      iex> list_scores()
      [%Score{}, ...]

  """
  def list_scores do
    Repo.all(Score)
  end

  @doc """
  Gets a single score.

  Raises `Ecto.NoResultsError` if the Score does not exist.

  ## Examples

      iex> get_score!(123)
      %Score{}

      iex> get_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_score!(id), do: Repo.get!(Score, id)

  @doc """
  Creates a score.

  ## Examples

      iex> create_score(%{field: value})
      {:ok, %Score{}}

      iex> create_score(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_score(attrs \\ %{}) do
    %Score{}
    |> Score.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a score.

  ## Examples

      iex> update_score(score, %{field: new_value})
      {:ok, %Score{}}

      iex> update_score(score, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_score(%Score{} = score, attrs) do
    score
    |> Score.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Score.

  ## Examples

      iex> delete_score(score)
      {:ok, %Score{}}

      iex> delete_score(score)
      {:error, %Ecto.Changeset{}}

  """
  def delete_score(%Score{} = score) do
    Repo.delete(score)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking score changes.

  ## Examples

      iex> change_score(score)
      %Ecto.Changeset{source: %Score{}}

  """
  def change_score(%Score{} = score) do
    Score.changeset(score, %{})
  end

  alias Mirror.Retrospectives.Feedback

  @doc """
  Returns the list of feedbacks.

  ## Examples

      iex> list_feedbacks()
      [%Feedback{}, ...]

  """
  def list_feedbacks do
    Repo.all(Feedback)
  end

  @doc """
  Gets a single feedback.

  Raises `Ecto.NoResultsError` if the Feedback does not exist.

  ## Examples

      iex> get_feedback!(123)
      %Feedback{}

      iex> get_feedback!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feedback!(id), do: Repo.get!(Feedback, id)

  @doc """
  Creates a feedback.

  ## Examples

      iex> create_feedback(%{field: value})
      {:ok, %Feedback{}}

      iex> create_feedback(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feedback(attrs \\ %{}) do
    %Feedback{}
    |> Feedback.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a feedback.

  ## Examples

      iex> update_feedback(feedback, %{field: new_value})
      {:ok, %Feedback{}}

      iex> update_feedback(feedback, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feedback(%Feedback{} = feedback, attrs) do
    feedback
    |> Feedback.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Feedback.

  ## Examples

      iex> delete_feedback(feedback)
      {:ok, %Feedback{}}

      iex> delete_feedback(feedback)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feedback(%Feedback{} = feedback) do
    Repo.delete(feedback)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feedback changes.

  ## Examples

      iex> change_feedback(feedback)
      %Ecto.Changeset{source: %Feedback{}}

  """
  def change_feedback(%Feedback{} = feedback) do
    Feedback.changeset(feedback, %{})
  end
end
