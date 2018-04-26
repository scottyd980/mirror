defmodule MirrorWeb.OrganizationView do
  use MirrorWeb, :view
  alias MirrorWeb.OrganizationView

  use JaSerializer.PhoenixView

  alias MirrorWeb.{UserSerializer, TeamSerializer}

  attributes [:name, :is_anonymous]

  has_many :members,
    links: [
      self: "/api/users/"
    ],
    serializer: UserSerializer,
    include: false,
    identifiers: :always

  has_many :admins,
    links: [
      self: "/api/users/"
    ],
    serializer: UserSerializer,
    include: false,
    identifiers: :always

  has_many :teams,
    links: [
      self: "/api/teams/"
    ],
    serializer: TeamSerializer,
    include: false,
    identifiers: :always

  def id(struct, conn) do
    struct.uuid
  end

  def render("delete.json-api", _) do
    %{meta: %{}}
  end
end
