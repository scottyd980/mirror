defmodule MirrorWeb.RetrospectiveScoreSubmissionView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView
  
  alias MirrorWeb.{UserSerializer, RetrospectiveSerializer}

  attributes [:submitted]

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

  def type, do: "score-submission"
end
