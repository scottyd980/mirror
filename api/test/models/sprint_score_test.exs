defmodule Mirror.SprintScoreTest do
  use Mirror.ModelCase

  alias Mirror.SprintScore

  @valid_attrs %{score: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SprintScore.changeset(%SprintScore{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SprintScore.changeset(%SprintScore{}, @invalid_attrs)
    refute changeset.valid?
  end
end
