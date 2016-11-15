defmodule Mirror.RetrospectiveChannel do
  use Mirror.Web, :channel

  def join("retrospectives:" <> retrospective_id, _params, socket) do
    {:ok, assign(socket, :retrospective_id, String.to_integer(retrospective_id))}
  end
end
