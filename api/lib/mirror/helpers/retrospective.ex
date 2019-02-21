defmodule Mirror.Helpers.Retrospective do
  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.{Retrospective, Feedback}

  def setup_feedback(feedback) do
    feedback = feedback
    |> Feedback.preload_relationships()

    retrospective = feedback.retrospective
    |> Retrospective.preload_relationships()

    handle_game(retrospective.game, retrospective, feedback)
  end

  defp handle_game(game, retrospective, feedback) do
    case game.name do
      "Sticky Notes" -> handle_sticky_notes(retrospective, feedback)
      "Three Little Pigs" -> handle_three_little_pigs(retrospective, feedback)
      _ -> {:noreply}
    end
  end

  defp handle_sticky_notes(retrospective, feedback) do
    case feedback.category do
      "positive" ->
        case Enum.any?(retrospective.feedbacks, fn fb -> fb.state == 1 && fb.category == "positive" end) do
          true -> {:noreply}
          false -> {:ok, %{"state" => 1}}
        end
      "negative" ->
        case Enum.any?(retrospective.feedbacks, fn fb -> fb.state == 1 && fb.category == "negative" end) do
          true -> {:noreply}
          false -> {:ok, %{"state" => 1}}
        end
      _ -> {:noreply}
    end
  end

  defp handle_three_little_pigs(retrospective, feedback) do
    case feedback.category do
      "straw" ->
        case Enum.any?(retrospective.feedbacks, fn fb -> fb.state == 1 && fb.category == "straw" end) do
          true -> {:noreply}
          false -> {:ok, %{"state" => 1}}
        end
      "stick" ->
        case Enum.any?(retrospective.feedbacks, fn fb -> fb.state == 1 && fb.category == "stick" end) do
          true -> {:noreply}
          false -> {:ok, %{"state" => 1}}
        end
      "brick" ->
        case Enum.any?(retrospective.feedbacks, fn fb -> fb.state == 1 && fb.category == "brick" end) do
          true -> {:noreply}
          false -> {:ok, %{"state" => 1}}
        end
      _ -> {:noreply}
    end
  end
end
