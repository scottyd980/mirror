defmodule Mirror.UserTest do
  use Mirror.ModelCase

  alias Mirror.User

  @valid_attrs %{email: "test@test.com", password: "test123", password_confirmation: "test123", username: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end


  test "mis-matched password_confirmation doesn't work" do
    changeset = User.changeset(%User{}, %{email: "joe@example.com",
      password: "1lh2bj1rjbk2",
      password_confirmation: "b1bk23jkn12",
      username: "some content"})
    refute changeset.valid?
  end

  test "missing password_confirmation doesn't work" do
    changeset = User.changeset(%User{}, %{email: "joe@example.com",
      password: "1lh2bj1rjbk2",
      username: "some content"})
    refute changeset.valid?
  end

  test "short password doesn't work" do
    changeset = User.changeset(%User{}, %{email: "joe@example.com",
      password: "1lh2d",
      password_confirmation: "1lh2d",
      username: "some content"})
    refute changeset.valid?
  end
end
