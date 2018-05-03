defmodule MirrorWeb.RetrospectiveParticipantController do
  use MirrorWeb, :controller

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.{Retrospective, Participant}
  
  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def create(conn, %{"retrospective_id" => retrospective_id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    retrospective = Retrospectives.get_retrospective!(retrospective_id)
    |> Retrospective.preload_relationships()

    case Helpers.User.user_is_team_member?(current_user, retrospective.team) do
      true ->
        with {:ok, %Participant{} = participant} <- Retrospectives.create_participant(%{user_id: current_user.id, retrospective_id: retrospective_id}) do
          updated_retrospective = Retrospectives.get_retrospective!(retrospective.id)
          |> Retrospective.preload_relationships()

          MirrorWeb.Endpoint.broadcast("retrospective:#{retrospective.id}", "joined_retrospective", MirrorWeb.RetrospectiveView.render("show.json-api", data: updated_retrospective))
          
          conn
          |> put_status(:created)
          |> render("show.json-api", data: participant)
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
        end
      _ ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end
end
