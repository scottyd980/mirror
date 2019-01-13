defmodule Mirror.TeamTest do
  use Mirror.ModelCase

  alias Mirror.Team

  @valid_attrs %{avatar: "some content", isAnonymous: true, name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Team.changeset(%Team{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Team.changeset(%Team{}, @invalid_attrs)
    refute changeset.valid?
  end
end
