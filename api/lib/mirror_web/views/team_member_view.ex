defmodule MirrorWeb.TeamMemberView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView

  alias MirrorWeb.{UserSerializer, TeamSerializer}

  has_one :team,
    links: [
      self: "/api/teams/"
    ],
    serializer: TeamSerializer,
    include: false,
    identifiers: :always

  has_one :user,
    links: [
      self: "/api/users/"
    ],
    serializer: UserSerializer,
    include: false,
    identifiers: :always

  def render("delete.json-api", _) do
    %{meta: %{}}
  end
end
