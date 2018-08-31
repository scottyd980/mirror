defmodule MirrorWeb.MemberDelegateController do
  use MirrorWeb, :controller

  alias Mirror.Teams
  alias Mirror.Teams.{Team, MemberDelegate}

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def create(conn, %{"data" => data}) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    team = Teams.get_team!(data["team_id"])
    |> Team.preload_relationships

    member_delegates = data["delegates"]

    case Helpers.User.user_is_team_admin?(current_user, team) do
      false ->
        conn
        |> put_status(404)
        |> render(MirrorWeb.ErrorView, "404.json-api", %{})
      true ->
        with {:ok, _} <- Teams.create_member_delegates(team, member_delegates) do
          conn
          |> put_status(:created)
          |> render("show.json-api", %{})
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: changeset)
          _ ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(MirrorWeb.ChangesetView, "error.json-api", changeset: %{})
        end
    end
  end
end
