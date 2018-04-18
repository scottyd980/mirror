defmodule Mirror.RetrospectivesTest do
  use Mirror.DataCase

  alias Mirror.Retrospectives

  describe "retrospectives" do
    alias Mirror.Retrospectives.Retrospective

    @valid_attrs %{cancelled: true, is_anonymous: true, name: "some name", state: 42}
    @update_attrs %{cancelled: false, is_anonymous: false, name: "some updated name", state: 43}
    @invalid_attrs %{cancelled: nil, is_anonymous: nil, name: nil, state: nil}

    def retrospective_fixture(attrs \\ %{}) do
      {:ok, retrospective} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Retrospectives.create_retrospective()

      retrospective
    end

    test "list_retrospectives/0 returns all retrospectives" do
      retrospective = retrospective_fixture()
      assert Retrospectives.list_retrospectives() == [retrospective]
    end

    test "get_retrospective!/1 returns the retrospective with given id" do
      retrospective = retrospective_fixture()
      assert Retrospectives.get_retrospective!(retrospective.id) == retrospective
    end

    test "create_retrospective/1 with valid data creates a retrospective" do
      assert {:ok, %Retrospective{} = retrospective} = Retrospectives.create_retrospective(@valid_attrs)
      assert retrospective.cancelled == true
      assert retrospective.is_anonymous == true
      assert retrospective.name == "some name"
      assert retrospective.state == 42
    end

    test "create_retrospective/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Retrospectives.create_retrospective(@invalid_attrs)
    end

    test "update_retrospective/2 with valid data updates the retrospective" do
      retrospective = retrospective_fixture()
      assert {:ok, retrospective} = Retrospectives.update_retrospective(retrospective, @update_attrs)
      assert %Retrospective{} = retrospective
      assert retrospective.cancelled == false
      assert retrospective.is_anonymous == false
      assert retrospective.name == "some updated name"
      assert retrospective.state == 43
    end

    test "update_retrospective/2 with invalid data returns error changeset" do
      retrospective = retrospective_fixture()
      assert {:error, %Ecto.Changeset{}} = Retrospectives.update_retrospective(retrospective, @invalid_attrs)
      assert retrospective == Retrospectives.get_retrospective!(retrospective.id)
    end

    test "delete_retrospective/1 deletes the retrospective" do
      retrospective = retrospective_fixture()
      assert {:ok, %Retrospective{}} = Retrospectives.delete_retrospective(retrospective)
      assert_raise Ecto.NoResultsError, fn -> Retrospectives.get_retrospective!(retrospective.id) end
    end

    test "change_retrospective/1 returns a retrospective changeset" do
      retrospective = retrospective_fixture()
      assert %Ecto.Changeset{} = Retrospectives.change_retrospective(retrospective)
    end
  end
end
