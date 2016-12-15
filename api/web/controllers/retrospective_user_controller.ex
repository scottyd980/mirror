defmodule Mirror.RetrospectiveUserController do
  use Mirror.Web, :controller

  alias Mirror.User
  alias Mirror.Team
  alias Mirror.Retrospective
  alias Mirror.RetrospectiveUser
  alias Mirror.UserHelper

  import Logger

  plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler

  def create(conn, %{"retrospective_id" => retrospective_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    retrospective = Repo.get!(Retrospective, retrospective_id)
    |> Repo.preload([:team, :moderator, :type, :participants])

    team = retrospective.team
    |> Repo.preload([:members])

    cond do
      UserHelper.user_is_team_member?(current_user, team) ->
        handle_add_retrospective_participant(conn, current_user, retrospective)
      true ->
        use_error_view(conn, 401, %{})
    end

  end

  defp handle_add_retrospective_participant(conn, user, retrospective) do

    cond do
        UserHelper.user_is_participant?(user, retrospective) ->
            conn
            |> put_status(:ok)
            |> render(Mirror.RetrospectiveUserView, "show.json", retrospective_user: %{retrospective_id: retrospective.id, user_id: user.id})
        true ->
            changeset = %RetrospectiveUser{}
            |> RetrospectiveUser.changeset(%{user_id: user.id, retrospective_id: retrospective.id})
            
            case Repo.insert changeset do
                {:ok, retrospective_user} ->
                    updated_retrospective = Repo.get!(Retrospective, retrospective.id)
                    |> Repo.preload([:team, :moderator, :type, :participants])

                    Mirror.Endpoint.broadcast("retrospective:#{retrospective.id}", "joined_retrospective", Mirror.RetrospectiveView.render("show.json", retrospective: updated_retrospective))

                    conn
                    |> put_status(:created)
                    |> render(Mirror.RetrospectiveUserView, "show.json", retrospective_user: retrospective_user)
                {:error, changeset} ->
                    use_error_view(conn, 422, changeset)
            end
    end
  end

  defp use_error_view(conn, status, changeset) do
    conn
    |> put_status(status)
    |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
  end
end
