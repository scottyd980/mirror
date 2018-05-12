defmodule MirrorWeb.TeamMemberController do
  use MirrorWeb, :controller

  alias Mirror.Teams
  alias Mirror.Accounts
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
                 {:ok, %MemberDelegate{} = _member_delegate} <- Teams.update_member_delegate(member_delegate, %{is_accessed: true})
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

  def delete(conn, %{"user_id" => user_id, "team_id" => team_id}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    team = Teams.get_team!(team_id)
    user = Accounts.get_user!(user_id)
    member = Teams.get_member!(%{user_id: user.id, team_id: team.id})

    case Helpers.User.user_is_team_admin?(current_user, team) || current_user.id == user.id do
      true ->
        with {:ok, _} <- Teams.delete_member(member) do
          conn
          |> put_status(:ok)
          |> render("delete.json-api")
        else 
          {:error, :no_additional_admins} ->
            conn
            |> put_status(403)
            |> render(MirrorWeb.ErrorView, "403.json-api")
          _ -> 
            conn
            |> put_status(422)
            |> render(MirrorWeb.ErrorView, "422.json-api")
        end
      false ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api")
    end
  end
end
