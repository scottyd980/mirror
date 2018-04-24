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

  describe "participants" do
    alias Mirror.Retrospectives.Participant

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def participant_fixture(attrs \\ %{}) do
      {:ok, participant} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Retrospectives.create_participant()

      participant
    end

    test "list_participants/0 returns all participants" do
      participant = participant_fixture()
      assert Retrospectives.list_participants() == [participant]
    end

    test "get_participant!/1 returns the participant with given id" do
      participant = participant_fixture()
      assert Retrospectives.get_participant!(participant.id) == participant
    end

    test "create_participant/1 with valid data creates a participant" do
      assert {:ok, %Participant{} = participant} = Retrospectives.create_participant(@valid_attrs)
    end

    test "create_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Retrospectives.create_participant(@invalid_attrs)
    end

    test "update_participant/2 with valid data updates the participant" do
      participant = participant_fixture()
      assert {:ok, participant} = Retrospectives.update_participant(participant, @update_attrs)
      assert %Participant{} = participant
    end

    test "update_participant/2 with invalid data returns error changeset" do
      participant = participant_fixture()
      assert {:error, %Ecto.Changeset{}} = Retrospectives.update_participant(participant, @invalid_attrs)
      assert participant == Retrospectives.get_participant!(participant.id)
    end

    test "delete_participant/1 deletes the participant" do
      participant = participant_fixture()
      assert {:ok, %Participant{}} = Retrospectives.delete_participant(participant)
      assert_raise Ecto.NoResultsError, fn -> Retrospectives.get_participant!(participant.id) end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = participant_fixture()
      assert %Ecto.Changeset{} = Retrospectives.change_participant(participant)
    end
  end

  describe "scores" do
    alias Mirror.Retrospectives.Score

    @valid_attrs %{score: 42}
    @update_attrs %{score: 43}
    @invalid_attrs %{score: nil}

    def score_fixture(attrs \\ %{}) do
      {:ok, score} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Retrospectives.create_score()

      score
    end

    test "list_scores/0 returns all scores" do
      score = score_fixture()
      assert Retrospectives.list_scores() == [score]
    end

    test "get_score!/1 returns the score with given id" do
      score = score_fixture()
      assert Retrospectives.get_score!(score.id) == score
    end

    test "create_score/1 with valid data creates a score" do
      assert {:ok, %Score{} = score} = Retrospectives.create_score(@valid_attrs)
      assert score.score == 42
    end

    test "create_score/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Retrospectives.create_score(@invalid_attrs)
    end

    test "update_score/2 with valid data updates the score" do
      score = score_fixture()
      assert {:ok, score} = Retrospectives.update_score(score, @update_attrs)
      assert %Score{} = score
      assert score.score == 43
    end

    test "update_score/2 with invalid data returns error changeset" do
      score = score_fixture()
      assert {:error, %Ecto.Changeset{}} = Retrospectives.update_score(score, @invalid_attrs)
      assert score == Retrospectives.get_score!(score.id)
    end

    test "delete_score/1 deletes the score" do
      score = score_fixture()
      assert {:ok, %Score{}} = Retrospectives.delete_score(score)
      assert_raise Ecto.NoResultsError, fn -> Retrospectives.get_score!(score.id) end
    end

    test "change_score/1 returns a score changeset" do
      score = score_fixture()
      assert %Ecto.Changeset{} = Retrospectives.change_score(score)
    end
  end

  describe "feedbacks" do
    alias Mirror.Retrospectives.Feedback

    @valid_attrs %{category: "some category", message: "some message", state: 42}
    @update_attrs %{category: "some updated category", message: "some updated message", state: 43}
    @invalid_attrs %{category: nil, message: nil, state: nil}

    def feedback_fixture(attrs \\ %{}) do
      {:ok, feedback} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Retrospectives.create_feedback()

      feedback
    end

    test "list_feedbacks/0 returns all feedbacks" do
      feedback = feedback_fixture()
      assert Retrospectives.list_feedbacks() == [feedback]
    end

    test "get_feedback!/1 returns the feedback with given id" do
      feedback = feedback_fixture()
      assert Retrospectives.get_feedback!(feedback.id) == feedback
    end

    test "create_feedback/1 with valid data creates a feedback" do
      assert {:ok, %Feedback{} = feedback} = Retrospectives.create_feedback(@valid_attrs)
      assert feedback.category == "some category"
      assert feedback.message == "some message"
      assert feedback.state == 42
    end

    test "create_feedback/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Retrospectives.create_feedback(@invalid_attrs)
    end

    test "update_feedback/2 with valid data updates the feedback" do
      feedback = feedback_fixture()
      assert {:ok, feedback} = Retrospectives.update_feedback(feedback, @update_attrs)
      assert %Feedback{} = feedback
      assert feedback.category == "some updated category"
      assert feedback.message == "some updated message"
      assert feedback.state == 43
    end

    test "update_feedback/2 with invalid data returns error changeset" do
      feedback = feedback_fixture()
      assert {:error, %Ecto.Changeset{}} = Retrospectives.update_feedback(feedback, @invalid_attrs)
      assert feedback == Retrospectives.get_feedback!(feedback.id)
    end

    test "delete_feedback/1 deletes the feedback" do
      feedback = feedback_fixture()
      assert {:ok, %Feedback{}} = Retrospectives.delete_feedback(feedback)
      assert_raise Ecto.NoResultsError, fn -> Retrospectives.get_feedback!(feedback.id) end
    end

    test "change_feedback/1 returns a feedback changeset" do
      feedback = feedback_fixture()
      assert %Ecto.Changeset{} = Retrospectives.change_feedback(feedback)
    end
  end

  describe "games" do
    alias Mirror.Retrospectives.Game

    @valid_attrs %{finished_state: 42, name: "some name"}
    @update_attrs %{finished_state: 43, name: "some updated name"}
    @invalid_attrs %{finished_state: nil, name: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Retrospectives.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Retrospectives.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Retrospectives.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Retrospectives.create_game(@valid_attrs)
      assert game.finished_state == 42
      assert game.name == "some name"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Retrospectives.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, game} = Retrospectives.update_game(game, @update_attrs)
      assert %Game{} = game
      assert game.finished_state == 43
      assert game.name == "some updated name"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Retrospectives.update_game(game, @invalid_attrs)
      assert game == Retrospectives.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Retrospectives.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Retrospectives.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Retrospectives.change_game(game)
    end
  end
end
