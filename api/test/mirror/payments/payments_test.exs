defmodule Mirror.PaymentsTest do
  use Mirror.DataCase

  alias Mirror.Payments

  describe "cards" do
    alias Mirror.Payments.Card

    @valid_attrs %{brand: "some brand", card_id: "some card_id", exp_month: 42, exp_year: 42, last4: "some last4", organization_id: 42, token_id: "some token_id", zip_code: "some zip_code"}
    @update_attrs %{brand: "some updated brand", card_id: "some updated card_id", exp_month: 43, exp_year: 43, last4: "some updated last4", organization_id: 43, token_id: "some updated token_id", zip_code: "some updated zip_code"}
    @invalid_attrs %{brand: nil, card_id: nil, exp_month: nil, exp_year: nil, last4: nil, organization_id: nil, token_id: nil, zip_code: nil}

    def card_fixture(attrs \\ %{}) do
      {:ok, card} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_card()

      card
    end

    test "list_cards/0 returns all cards" do
      card = card_fixture()
      assert Payments.list_cards() == [card]
    end

    test "get_card!/1 returns the card with given id" do
      card = card_fixture()
      assert Payments.get_card!(card.id) == card
    end

    test "create_card/1 with valid data creates a card" do
      assert {:ok, %Card{} = card} = Payments.create_card(@valid_attrs)
      assert card.brand == "some brand"
      assert card.card_id == "some card_id"
      assert card.exp_month == 42
      assert card.exp_year == 42
      assert card.last4 == "some last4"
      assert card.organization_id == 42
      assert card.token_id == "some token_id"
      assert card.zip_code == "some zip_code"
    end

    test "create_card/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_card(@invalid_attrs)
    end

    test "update_card/2 with valid data updates the card" do
      card = card_fixture()
      assert {:ok, card} = Payments.update_card(card, @update_attrs)
      assert %Card{} = card
      assert card.brand == "some updated brand"
      assert card.card_id == "some updated card_id"
      assert card.exp_month == 43
      assert card.exp_year == 43
      assert card.last4 == "some updated last4"
      assert card.organization_id == 43
      assert card.token_id == "some updated token_id"
      assert card.zip_code == "some updated zip_code"
    end

    test "update_card/2 with invalid data returns error changeset" do
      card = card_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_card(card, @invalid_attrs)
      assert card == Payments.get_card!(card.id)
    end

    test "delete_card/1 deletes the card" do
      card = card_fixture()
      assert {:ok, %Card{}} = Payments.delete_card(card)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_card!(card.id) end
    end

    test "change_card/1 returns a card changeset" do
      card = card_fixture()
      assert %Ecto.Changeset{} = Payments.change_card(card)
    end
  end
end
