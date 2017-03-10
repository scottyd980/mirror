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
    get "/teams/:id/next_sprint", TeamController, :get_next_sprint
    post "/retrospective_users", RetrospectiveUserController, :create
    post "/team_users", UserTeamController, :create
    post "/team_admins", TeamAdminController, :create
    delete "/team_users", UserTeamController, :delete
    delete "/team_admins", TeamAdminController, :delete

    resources "/teams", TeamController
    resources "/retrospectives", RetrospectiveController, only: [:index, :create, :update, :show]
    resources "/scores", SprintScoreController, only: [:create, :show]
    resources "/feedbacks", FeedbackController, only: [:create, :show, :update]
    resources "/users", UserController, only: [:show]
    resources "/organizations", OrganizationController, only: [:index, :create, :show, :update]
    resources "/cards", CardController, only: [:index, :create, :delete]
    
  end
end
