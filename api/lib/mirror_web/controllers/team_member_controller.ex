defmodule MirrorWeb.TeamMemberController do
  use MirrorWeb, :controller

  alias Mirror.Teams
  alias Mirror.Teams.Member

  action_fallback MirrorWeb.FallbackController

  # TODO: Work
  # def create(conn, %{"member" => member_params}) do
  #   with {:ok, %Member{} = member} <- Teams.create_member(member_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", team_member_path(conn, :show, member))
  #     |> render("show.json", member: member)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   member = Teams.get_member!(id)
  #   with {:ok, %Member{}} <- Teams.delete_member(member) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
