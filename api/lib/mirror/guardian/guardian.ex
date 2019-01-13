defmodule Mirror.Guardian do
    use Guardian, otp_app: :mirror

    alias Mirror.Repo
    alias Mirror.Accounts.User

    def subject_for_token(resource = %User{}, _claims), do: { :ok, "User:#{resource.id}" }
    def subject_for_token(_, _), do: { :error, "Unknown resource type" }

    def resource_from_claims(%{"sub" => "User:" <> id}), do: { :ok, Repo.get(User, id) }
    def resource_from_claims(_claims), do: { :error, "Unknown resource type" }
end