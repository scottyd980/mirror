defmodule Mirror.CardTest do
  use Mirror.ModelCase

  alias Mirror.Card

  @valid_attrs %{brand: "some content", card_id: "some content", exp_month: 42, exp_year: 42, last4: "some content", token_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Card.changeset(%Card{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Card.changeset(%Card{}, @invalid_attrs)
    refute changeset.valid?
  end
end
