defmodule MirrorWeb.RetrospectiveView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView
  
  alias MirrorWeb.TeamSerializer
  alias MirrorWeb.UserSerializer

  attributes [:name, :state, :is_anonymous, :cancelled]

  has_one :team,
    links: [
      self: "/api/teams/"
    ],
    serializer: TeamSerializer,
    include: false,
    identifiers: :always

  has_one :moderator,
    links: [
      self: "/api/users/"
    ],
    serializer: UserSerializer,
    include: false,
    identifiers: :always
end
