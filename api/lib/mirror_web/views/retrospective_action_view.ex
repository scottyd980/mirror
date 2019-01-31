defmodule MirrorWeb.RetrospectiveActionView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView

  alias MirrorWeb.{UserSerializer, FeedbackSerializer}

  attributes [:message]

  has_one :user,
    links: [
      self: "/api/users/"
    ],
    serializer: UserSerializer,
    include: false,
    identifiers: :always

  has_one :feedback,
    links: [
      self: "/api/feedback/"
    ],
    serializer: FeedbackSerializer,
    include: false,
    identifiers: :always

  def type, do: "action"
  def render("delete.json-api", _) do
    %{meta: %{}}
  end
end
