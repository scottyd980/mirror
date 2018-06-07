defmodule MirrorWeb.OrganizationView do
  use MirrorWeb, :view

  use JaSerializer.PhoenixView

  alias MirrorWeb.{UserSerializer, TeamSerializer, CardSerializer}

  attributes [:name, :is_anonymous, :billing_status, :billing_frequency, :billing_customer]

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

  has_many :cards,
    links: [
      self: "/api/cards"
    ],
    serializer: CardSerializer,
    include: false,
    identifiers: :always

  has_one :default_payment,
    links: [
      self: "/api/cards"
    ],
    serializer: CardSerializer,
    include: false,
    identifiers: :always

  has_many :teams,
    links: [
      self: "/api/teams/"
    ],
    serializer: TeamSerializer,
    include: false,
    identifiers: :always

  def id(struct, _conn) do
    struct.uuid
  end

  def render("delete.json-api", _) do
    %{meta: %{}}
  end
end
