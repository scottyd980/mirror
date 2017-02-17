defmodule Mirror.Router do
  use Mirror.Web, :router

  # Unauthenticated Requests
  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  # Authenticated Requests
  pipeline :api_auth do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/api", Mirror do
    pipe_through :api
    # Registration
    post "/register", RegistrationController, :create
    # Login
    post "/token", SessionController, :create, as: :login
  end

  scope "/api", Mirror do
    pipe_through :api_auth
    get "/user/current", UserController, :current

    resources "/teams", TeamController
    get "/teams/:id/next_sprint", TeamController, :get_next_sprint
    
    resources "/retrospectives", RetrospectiveController, only: [:index, :create, :update, :show, :delete]
    
    resources "/scores", SprintScoreController, only: [:create, :show]

    resources "/feedbacks", FeedbackController, only: [:create, :show, :update]

    post "/retrospective_users", RetrospectiveUserController, :create
    post "/team_users", UserTeamController, :create
    delete "/team_users", UserTeamController, :delete
    post "/team_admins", TeamAdminController, :create
    delete "/team_admins", TeamAdminController, :delete
    resources "/users", UserController, only: [:show]
  end
end
