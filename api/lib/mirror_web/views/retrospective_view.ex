defmodule MirrorWeb.RetrospectiveView do
  use MirrorWeb, :view
  use JaSerializer.PhoenixView

  alias MirrorWeb.{TeamSerializer, UserSerializer, ScoreSerializer, FeedbackSerializer, FeedbackSubmissionSerializer, ScoreSubmissionSerializer}
  alias MirrorWeb.UserSerializer

  attributes [:name, :state, :is_anonymous, :cancelled]

  has_one :team,
    links: [
      self: "/api/teams/"
    ],
    serializer: TeamSerializer,
    include: false,
    identifiers: :always

  has_one :moderator,
    links: [
      self: "/api/users/"
    ],
    serializer: UserSerializer,
    include: false,
    identifiers: :always

  has_many :participants,
    links: [
      self: "/api/users/"
    ],
    serializer: UserSerializer,
    include: false,
    identifiers: :always

  has_many :scores,
    links: [
      self: "/api/scores/"
    ],
    serializer: ScoreSerializer,
    include: false,
    identifiers: :always

  has_many :feedbacks,
    links: [
      self: "/api/feedbacks/"
    ],
    serializer: FeedbackSerializer,
    include: false,
    identifiers: :always

  has_many :feedback_submissions,
    links: [
      self: "/api/feedback-submissions/"
    ],
    serializer: FeedbackSubmissionSerializer,
    include: false,
    identifiers: :always

  has_many :score_submissions,
    links: [
      self: "/api/score-submissions/"
    ],
    serializer: ScoreSubmissionSerializer,
    include: false,
    identifiers: :always
end
