defmodule MirrorWeb.UserView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView
  
  alias MirrorWeb.TeamSerializer

  attributes [:username, :email]

  has_many :teams,
    links: [
      self: "/api/teams/"
    ],
    serializer: TeamSerializer,
    include: false,
    identifiers: :always
end
