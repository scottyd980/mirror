defmodule MirrorWeb.RetrospectiveFeedbackView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView

  require Logger
  
  alias MirrorWeb.{UserSerializer, ActionSerializer, RetrospectiveSerializer}

  attributes [:category, :message, :state, :uuid]

  has_one :user,
    links: [
      self: "/api/users/"
    ],
    serializer: UserSerializer,
    include: false,
    identifiers: :always,
    field: :user,
    type: "user"
  
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

  def user(feedback, conn) do
    case feedback.retrospective.is_anonymous do
      true ->
        case conn do
          nil -> nil
          _ ->
            current_user = Mirror.Guardian.Plug.current_resource(conn)

            case current_user.id == feedback.user.id do
              true -> feedback.user
              false -> nil
            end
        end
      false -> feedback.user
    end
  end

  def type, do: "feedback"
end
