defmodule MirrorWeb.RetrospectiveScoreView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView
  
  alias MirrorWeb.{UserSerializer, RetrospectiveSerializer}

  attributes [:score]

  has_one :user,
    links: [
      self: "/api/users/"
    ],
    serializer: UserSerializer,
    include: false,
    identifiers: :always
  
  has_one :retrospective,
    links: [
      self: "/api/retrospectives/"
    ],
    serializer: RetrospectiveSerializer,
    include: false,
    identifiers: :always

  def type, do: "score"
end
