defmodule Mirror.Router do
  use Mirror.Web, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  scope "/api", Mirror do
    pipe_through :api
    # Route stuff to our SessionController
    resources "/session", SessionController, only: [:index]
  end
end
