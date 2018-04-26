defmodule MirrorWeb.UserView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView
  
  alias MirrorWeb.{TeamSerializer, OrganizationSerializer}

  attributes [:username, :email]

  has_many :teams,
    links: [
      self: "/api/teams/"
    ],
    serializer: TeamSerializer,
    include: false,
    identifiers: :always
  
  has_many :organizations,
    links: [
      self: "/api/organizations/"
    ],
    serializer: OrganizationSerializer,
    include: false,
    identifiers: :always
end
