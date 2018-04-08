defmodule Mirror.ActionController do
    use Mirror.Web, :controller
  
    alias Mirror.{User, Retrospective, UserHelper, Feedback, Team, Action}
  
    plug Guardian.Plug.EnsureAuthenticated, handler: Mirror.AuthErrorHandler
  
    def create(conn, %{"data" => %{"attributes" => attributes, "relationships" => relationships, "type" => "actions"}}) do
      current_user = Guardian.Plug.current_resource(conn)

      feedback_id = relationships["feedback"]["data"]["id"]

      feedback = Repo.get!(Feedback, feedback_id)
      |> Feedback.preload_relationships()

      retrospective = feedback.retrospective

      case UserHelper.user_is_moderator?(current_user, retrospective) do
        true ->
          changeset = Action.changeset %Action{}, %{
              message: attributes["message"],
              feedback_id: feedback_id
          }
      
          case Repo.insert changeset do
              {:ok, action} ->
                  action = action
                  |> Action.preload_relationships
      
                  Mirror.Endpoint.broadcast("retrospective:#{feedback.retrospective.id}", "feedback_action_change", Mirror.ActionView.render("show.json", action: action))
      
                  conn
                  |> put_status(:created)
                  |> render(Mirror.ActionView, "show.json", action: action)
              {:error, changeset} ->
                  use_error_view(conn, 422, changeset)
          end
        _ ->
          conn
          |> put_status(404)
          |> render(Mirror.ErrorView, "404.json")
      end
    end
    
    def show(conn, %{"id" => id}) do
      current_user = Guardian.Plug.current_resource(conn)
      
      action = Repo.get!(Action, id)
      |> Action.preload_relationships()

      feedback = action.feedback
      |> Feedback.preload_relationships()

      retrospective = feedback.retrospective
      |> Retrospective.preload_relationships()

      team = retrospective.team

      case UserHelper.user_is_team_member?(current_user, team) do
        true ->
          render(conn, "show.json", action: action)
        _ ->
          conn
          |> put_status(404)
          |> render(Mirror.ErrorView, "404.json")
      end
    end
  
    def update(conn, %{"id" => id}) do
      current_user = Guardian.Plug.current_resource(conn)
  
      body_params = conn.body_params
      
      action = Repo.get!(Action, id)
      |> Action.preload_relationships()

      feedback = action.feedback
      |> Feedback.preload_relationships()

      retrospective = feedback.retrospective

      case UserHelper.user_is_moderator?(current_user, retrospective) do
        true ->
          message = body_params["data"]["attributes"]["message"];
  
          changeset = Action.changeset action, %{
              message: message
          }
        
          case Repo.update(changeset) do
            {:ok, action} ->
              Mirror.Endpoint.broadcast("retrospective:#{feedback.retrospective.id}", "feedback_action_change", Mirror.ActionView.render("show.json", action: action))
              render(conn, "show.json", action: action)
            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
          end
        _ ->
          conn
          |> put_status(404)
          |> render(Mirror.ErrorView, "404.json")
      end
    end

    def delete(conn, %{"id" => id}) do
        current_user = Guardian.Plug.current_resource(conn)
    
        action = Repo.get!(Action, id)
        |> Action.preload_relationships()

        feedback = action.feedback
        |> Feedback.preload_relationships()

        retrospective = feedback.retrospective

        case UserHelper.user_is_moderator?(current_user, retrospective) do
          true ->
            case Repo.delete(action) do
              {:ok, action} ->
                  Mirror.Endpoint.broadcast("retrospective:#{feedback.retrospective.id}", "feedback_action_deleted", Mirror.ActionView.render("show.json", action: action))
                  render(conn, "delete.json", action: action)
              {:error, changeset} ->
                  conn
                  |> put_status(:unprocessable_entity)
                  |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
            end
          _ ->
            conn
            |> put_status(404)
            |> render(Mirror.ErrorView, "404.json")
        end
    end
  
    defp use_error_view(conn, status, changeset) do
      conn
      |> put_status(status)
      |> render(Mirror.ChangesetView, "error.json", changeset: changeset)
    end
  end
  