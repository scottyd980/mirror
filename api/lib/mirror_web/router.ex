defmodule MirrorWeb.Router do
  use MirrorWeb, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  pipeline :auth do
    plug Mirror.Guardian.AuthPipeline
  end

  pipeline :json_api do
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  # NON-JSON API Endpoints - Open endpoints
  scope "/api", MirrorWeb do
    pipe_through [:api]

    post "/token", UserController, :login
  end
  
  # NON-JSON API Endpoints - Authorized endpoints
  scope "/api", MirrorWeb do
    pipe_through [:api, :auth]
    
    get "/user/current", UserController, :current
    post "/team_members", TeamMemberController, :create
    delete "/team_members", TeamMemberController, :delete
    post "/team_admins", TeamAdminController, :create
    delete "/team_admins", TeamAdminController, :delete
    get "/teams/:id/next_sprint", TeamController, :find_next_sprint
    post "/retrospective_participants", RetrospectiveParticipantController, :create
  end

  # JSON API Endpoints - Open endpoints
  scope "/api", MirrorWeb do
    pipe_through [:api, :json_api]

    post "/register", UserController, :create
  end

  # JSON API Endpoints - Authorized endpoints
  scope "/api", MirrorWeb do
    pipe_through [:api, :auth, :json_api]
    
    resources "/users", UserController, only: [:show]
    resources "/teams", TeamController
    resources "/retrospectives", RetrospectiveController, only: [:index, :create, :update, :show]
  end
end
