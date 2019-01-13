defmodule MirrorWeb.TeamView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView

  alias MirrorWeb.{UserSerializer, RetrospectiveSerializer, OrganizationSerializer}

  attributes [:name, :avatar, :is_anonymous]

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

  has_many :retrospectives,
    links: [
      self: "/api/retrospectives/"
    ],
    serializer: RetrospectiveSerializer,
    include: false,
    identifiers: :always

  has_one :organization,
    links: [
      self: "/api/organizations/"
    ],
    serializer: OrganizationSerializer,
    include: false,
    identifiers: :always

  def id(struct, _conn) do
    struct.uuid
  end

  def render("next_sprint.json-api", %{next_sprint: next_sprint, team: team}) do
    %{
      "id": team.uuid,
      "next_sprint": next_sprint
    }
  end

  def render("delete.json-api", _) do
    %{meta: %{}}
  end
end
