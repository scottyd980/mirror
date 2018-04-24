defmodule MirrorWeb.OrganizationMemberController do
  use MirrorWeb, :controller

  alias Mirror.Organizations
  alias Mirror.Organizations.Member

  action_fallback MirrorWeb.FallbackController

  # TODO: WORK
  # def index(conn, _params) do
  #   members = Organizations.list_members()
  #   render(conn, "index.json", members: members)
  # end

  # def create(conn, %{"member" => member_params}) do
  #   with {:ok, %Member{} = member} <- Organizations.create_member(member_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", member_path(conn, :show, member))
  #     |> render("show.json", member: member)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   member = Organizations.get_member!(id)
  #   render(conn, "show.json", member: member)
  # end

  # def update(conn, %{"id" => id, "member" => member_params}) do
  #   member = Organizations.get_member!(id)

  #   with {:ok, %Member{} = member} <- Organizations.update_member(member, member_params) do
  #     render(conn, "show.json", member: member)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   member = Organizations.get_member!(id)
  #   with {:ok, %Member{}} <- Organizations.delete_member(member) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
