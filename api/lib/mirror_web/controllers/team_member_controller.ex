defmodule MirrorWeb.TeamMemberController do
  use MirrorWeb, :controller

  alias Mirror.Teams
  alias Mirror.Teams.{Member, MemberDelegate}

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  # TODO: Work
  def create(conn, %{"access-code" => access_code}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    member_delegate = Teams.get_member_delegate!(access_code)
    |> MemberDelegate.preload_relationships

    case Helpers.User.user_is_team_member?(current_user, member_delegate.team) do
      false ->
        case member_delegate.is_accessed do
          true ->
            conn
            |> put_status(404)
            |> render(MirrorWeb.ErrorView, "404.json-api", %{})
          false ->
            with {:ok, %Member{} = member} <- Teams.create_member(%{team_id: member_delegate.team.id, user_id: current_user.id}),
                 {:ok, %MemberDelegate{} = member_delegate} <- Teams.update_member_delegate(member_delegate, %{is_accessed: true})
            do
              conn
              |> put_status(:created)
              |> render("show.json-api", data: member |> Member.preload_relationships)
            end
        end
      true ->
        conn
        |> put_status(:ok)
        |> render("show.json-api", data: %{team: member_delegate.team, user: current_user})
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   member = Teams.get_member!(id)
  #   with {:ok, %Member{}} <- Teams.delete_member(member) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
