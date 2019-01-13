defmodule Mirror.Guardian.AuthPipeline do
    use Guardian.Plug.Pipeline, otp_app: :mirror

    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated
end