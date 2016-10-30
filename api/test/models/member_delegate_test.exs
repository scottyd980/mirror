defmodule Mirror.MemberDelegateTest do
  use Mirror.ModelCase

  alias Mirror.MemberDelegate

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = MemberDelegate.changeset(%MemberDelegate{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MemberDelegate.changeset(%MemberDelegate{}, @invalid_attrs)
    refute changeset.valid?
  end
end
