defmodule MirrorWeb.AdminController do
  use MirrorWeb, :controller

  alias Mirror.Organizations
  alias Mirror.Organizations.Admin

  action_fallback MirrorWeb.FallbackController

  # TODO: WORK
  # def index(conn, _params) do
  #   admins = Organizations.list_admins()
  #   render(conn, "index.json", admins: admins)
  # end

  # def create(conn, %{"admin" => admin_params}) do
  #   with {:ok, %Admin{} = admin} <- Organizations.create_admin(admin_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", admin_path(conn, :show, admin))
  #     |> render("show.json", admin: admin)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   admin = Organizations.get_admin!(id)
  #   render(conn, "show.json", admin: admin)
  # end

  # def update(conn, %{"id" => id, "admin" => admin_params}) do
  #   admin = Organizations.get_admin!(id)

  #   with {:ok, %Admin{} = admin} <- Organizations.update_admin(admin, admin_params) do
  #     render(conn, "show.json", admin: admin)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   admin = Organizations.get_admin!(id)
  #   with {:ok, %Admin{}} <- Organizations.delete_admin(admin) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
