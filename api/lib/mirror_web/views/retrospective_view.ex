defmodule MirrorWeb.RetrospectiveView do
  use MirrorWeb, :view
  alias MirrorWeb.RetrospectiveView

  def render("index.json", %{retrospectives: retrospectives}) do
    %{data: render_many(retrospectives, RetrospectiveView, "retrospective.json")}
  end

  def render("show.json", %{retrospective: retrospective}) do
    %{data: render_one(retrospective, RetrospectiveView, "retrospective.json")}
  end

  def render("retrospective.json", %{retrospective: retrospective}) do
    %{id: retrospective.id,
      name: retrospective.name,
      state: retrospective.state,
      is_anonymous: retrospective.is_anonymous,
      cancelled: retrospective.cancelled}
  end
end
