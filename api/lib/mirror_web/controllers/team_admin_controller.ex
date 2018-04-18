defmodule MirrorWeb.TeamAdminController do
  use MirrorWeb, :controller

  alias Mirror.Teams
  alias Mirror.Teams.Admin

  action_fallback MirrorWeb.FallbackController

  # TODO: WORK
  # def create(conn, %{"admin" => admin_params}) do
  #   with {:ok, %Admin{} = admin} <- Teams.create_admin(admin_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", team_admin_path(conn, :show, admin))
  #     |> render("show.json", admin: admin)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   admin = Teams.get_admin!(id)
  #   with {:ok, %Admin{}} <- Teams.delete_admin(admin) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
