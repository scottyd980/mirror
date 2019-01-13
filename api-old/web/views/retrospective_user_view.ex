defmodule Mirror.RetrospectiveUserView do
  use Mirror.Web, :view

  def render("index.json", %{retrospective_user: retrospective_users}) do
    %{data: render_many(retrospective_users, Mirror.RetrospectiveUserView, "retrospective_user.json")}
  end

  def render("show.json", %{retrospective_user: retrospective_user}) do
    %{data: render_one(retrospective_user, Mirror.RetrospectiveUserView, "retrospective_user.json")}
  end

  def render("delete.json", %{retrospective_user: retrospective_user}) do
    %{meta: %{}}
  end

  def render("retrospective_user.json", %{retrospective_user: retrospective_user}) do
    %{
        "type": "retrospective_user",
        "attributes": %{
            "retrospective_id": retrospective_user.retrospective_id,
            "user_id": retrospective_user.user_id
        }
    }
  end
end
