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
  end
end
