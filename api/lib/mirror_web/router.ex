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

    get "/kube_health", HealthController, :index
    post "/token", UserController, :login
    post "/forgot/username", UserController, :forgot_username
    post "/forgot/password", UserController, :forgot_password
    post "/stripe_webhooks", WebhookController, :create
  end

  # NON-JSON API Endpoints - Authorized endpoints
  scope "/api", MirrorWeb do
    pipe_through [:api, :auth]

    get "/user/current", UserController, :current
    get "/teams/:id/next_sprint", TeamController, :find_next_sprint
    get "/uuid", UUIDController, :index

    post "/retrospective_participants", RetrospectiveParticipantController, :create
    post "/team_admins", TeamAdminController, :create
    post "/team_members", TeamMemberController, :create
    post "/member_delegates", MemberDelegateController, :create

    delete "/team_members", TeamMemberController, :delete
    delete "/team_admins", TeamAdminController, :delete
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
    resources "/teams", TeamController, only: [:index, :create, :show, :update, :delete]
    resources "/retrospectives", RetrospectiveController, only: [:index, :create, :update, :show]
    resources "/feedbacks", RetrospectiveFeedbackController, only: [:create, :show, :update]
    resources "/feedback-submissions", RetrospectiveFeedbackSubmissionController, only: [:show]
    resources "/scores", RetrospectiveScoreController, only: [:create, :show, :update]
    resources "/score-submissions", RetrospectiveScoreSubmissionController, only: [:show]
    resources "/actions", RetrospectiveActionController, only: [:create, :show, :update, :delete]
    case Application.get_env(:mirror, :billing_active) do
      true ->
        resources "/organizations", OrganizationController, only: [:create, :show, :update, :delete]
        resources "/cards", PaymentCardController, only: [:index, :create, :show, :delete]
      _ -> nil
    end
  end
end
