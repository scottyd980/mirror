defmodule Mirror.ActionController do
    use Mirror.Web, :controller
  
    require Logger
  
    alias Mirror.{User, Retrospective, UserHelper, Feedback, Team, Action}
  
    plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler
  
    # TODO: Make sure current_user is a member of the team
    def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "actions"}}) do
      current_user = Guardian.Plug.current_resource(conn)
  
      feedback_id = relationships["feedback"]["data"]["id"]
  
      changeset = Action.changeset %Action{}, %{
          message: attributes["message"],
          feedback_id: feedback_id
      }
  
      case Repo.insert changeset do
          {:ok, action} ->
              action = action
              |> Action.preload_relationships
  
              # Mirror.Endpoint.broadcast("retrospective:#{retrospective_id}", "action_added", Mirror.FeedbackView.render("show.json", action: action))
  
              conn
              |> put_status(:created)
              |> render(Mirror.ActionView, "show.json", action: action)
          {:error, changeset} ->
              use_error_view(conn, 422, changeset)
      end
  
    end
    
    # TODO: Make sure current_user is a member of the team
    def show(conn, %{"id" => id}) do
      current_user = Guardian.Plug.current_resource(conn)
  
      action = Repo.get!(Action, id)
      |> Action.preload_relationships()
  
    #   retrospective = feedback.retrospective
    #   |> Retrospective.preload_relationships()
  
    #   team = retrospective.team
    #   |> Team.preload_relationships()
  
    #   case UserHelper.user_is_team_member?(current_user, team) do
    #     true ->
          render(conn, "show.json", action: action)
    #     _ ->
    #       use_error_view(conn, 401, %{})
    #   end
    end
  
    # TODO: Need to make sure this is a moderator of the retrospective making changes
    def update(conn, %{"id" => id}) do
      current_user = Guardian.Plug.current_resource(conn)
  
      body_params = conn.body_params
      
      action = Repo.get!(Action, id)
      |> Action.preload_relationships()
  
      message = body_params["data"]["attributes"]["message"];
  
      changeset = Action.changeset action, %{
          message: message
      }
    
      case Repo.update(changeset) do
        {:ok, action} ->
          # Mirror.Endpoint.broadcast("retrospective:#{feedback.retrospective.id}", "feedback_state_change", Mirror.FeedbackView.render("show.json", feedback: feedback))
          render(conn, "show.json", action: action)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
      end
    end
  
    defp use_error_view(conn, status, changeset) do
      conn
      |> put_status(status)
      |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end
  end
  