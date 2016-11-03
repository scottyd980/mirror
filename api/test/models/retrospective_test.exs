defmodule Mirror.RetrospectiveTest do
  use Mirror.ModelCase

  alias Mirror.Retrospective

  @valid_attrs %{name: "some content", isAnonymous: true, state: 0}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Retrospective.changeset(%Retrospective{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Retrospective.changeset(%Retrospective{}, @invalid_attrs)
    refute changeset.valid?
  end
end
