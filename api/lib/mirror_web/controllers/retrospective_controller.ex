defmodule MirrorWeb.RetrospectiveController do
  use MirrorWeb, :controller

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.Retrospective
  alias Mirror.Teams

  alias Mirror.Helpers

  action_fallback MirrorWeb.FallbackController

  def index(conn, params) do
    current_user = Mirror.Guardian.Plug.current_resource(conn)

    team = Teams.get_team!(params["filter"]["team"])
    case Helpers.User.user_is_team_member?(current_user, team) do
      true ->
        retrospectives = Retrospectives.list_retrospectives(team)
        render(conn, "index.json-api", data: retrospectives)
      _ ->
        conn
        |> put_status(404)
        |> render(Mirror.ErrorView, "404.json-api")
    end
  end

  # TODO: WORK
  # def create(conn, %{"retrospective" => retrospective_params}) do
  #   with {:ok, %Retrospective{} = retrospective} <- Retrospectives.create_retrospective(retrospective_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", retrospective_path(conn, :show, retrospective))
  #     |> render("show.json", retrospective: retrospective)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   retrospective = Retrospectives.get_retrospective!(id)
  #   render(conn, "show.json", retrospective: retrospective)
  # end

  # def update(conn, %{"id" => id, "retrospective" => retrospective_params}) do
  #   retrospective = Retrospectives.get_retrospective!(id)

  #   with {:ok, %Retrospective{} = retrospective} <- Retrospectives.update_retrospective(retrospective, retrospective_params) do
  #     render(conn, "show.json", retrospective: retrospective)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   retrospective = Retrospectives.get_retrospective!(id)
  #   with {:ok, %Retrospective{}} <- Retrospectives.delete_retrospective(retrospective) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
