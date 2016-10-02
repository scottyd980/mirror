defmodule Mirror.UserView do
  use Mirror.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Mirror.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Mirror.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
    	"type": "user",
    	"id": user.id,
    	"attributes": %{
        "username": user.username,
    		"email": user.email
    	}
    }
  end
end
