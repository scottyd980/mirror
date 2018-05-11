defmodule MirrorWeb.RetrospectiveFeedbackView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView
  
  alias MirrorWeb.{UserSerializer, ActionSerializer, RetrospectiveSerializer}

  attributes [:category, :message, :state]

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

  has_one :action,
    links: [
      self: "/api/actions/"
    ],
    serializer: ActionSerializer,
    include: false,
    identifiers: :always,
    field: :actions,
    type: "action"

  def action(feedback, _conn) do
    List.first(feedback.actions)
  end

  def type, do: "feedback"
end
