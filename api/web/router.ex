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

    resources "/team_users", UserTeamController, only: [:create]
    resources "/users", UserController, only: [:show]
  end
end
