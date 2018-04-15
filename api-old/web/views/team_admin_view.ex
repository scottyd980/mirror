defmodule Mirror.TeamAdminView do
  use Mirror.Web, :view

  def render("index.json", %{team_admin: team_admins}) do
    %{data: render_many(team_admins, Mirror.TeamAdminView, "team_admin.json")}
  end

  def render("show.json", %{team_admin: team_admin}) do
    %{data: render_one(team_admin, Mirror.TeamAdminView, "team_admin.json")}
  end

  def render("delete.json", %{team_admin: team_admin}) do
    %{meta: %{}}
  end

  def render("team_admin.json", %{team_admin: team_admin}) do
    %{
    	"type": "team_admin",
      "attributes": %{
      	"team_id": team_admin.team_id,
        "admin_id": team_admin.user_id
    	}
    }
  end
end
