defmodule MirrorWeb.RetrospectiveScoreView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView
  
  alias MirrorWeb.{UserSerializer, RetrospectiveSerializer}

  attributes [:score, :uuid]

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

  def user(score, conn) do
    case score.retrospective.is_anonymous do
      true ->
        case conn do
          nil -> nil
          _ ->
            current_user = Mirror.Guardian.Plug.current_resource(conn)

            case current_user.id == score.user.id do
              true -> score.user
              false -> nil
            end
        end
      false -> score.user
    end
  end

  def type, do: "score"
end
