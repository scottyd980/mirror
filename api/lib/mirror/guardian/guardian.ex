defmodule Mirror.Guardian do
    use Guardian, otp_app: :mirror

    alias Mirror.Repo
    alias Mirror.Accounts.User

    def subject_for_token(resource = %User{}, _claims), do: { :ok, "User:#{resource.id}" }
    def subject_for_token(_, _), do: { :error, "Unknown resource type" }

    def resource_from_claims(%{"sub" => "User:" <> id}) do
        user = Repo.get(User, id)

        if user do
            %Timber.Contexts.UserContext{id: user.id, email: user.email, name: user.username}
            |> Timber.add_context()
        end

        { :ok, user }
    end
    def resource_from_claims(_claims), do: { :error, "Unknown resource type" }
end
