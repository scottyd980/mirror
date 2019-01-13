defmodule MirrorWeb.RetrospectiveParticipantView do
    use MirrorWeb, :view
    use JaSerializer.PhoenixView
  
    attributes [:user_id, :retrospective_id]
end
  