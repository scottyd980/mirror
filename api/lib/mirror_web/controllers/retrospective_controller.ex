defmodule MirrorWeb.RetrospectiveController do
  use MirrorWeb, :controller

  alias Mirror.Retrospectives
  alias Mirror.Retrospectives.Retrospective

  action_fallback MirrorWeb.FallbackController

  # TODO: WORK
  # def index(conn, _params) do
  #   retrospectives = Retrospectives.list_retrospectives()
  #   render(conn, "index.json", retrospectives: retrospectives)
  # end

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
