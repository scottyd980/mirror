defmodule Mirror.RetrospectiveChannel do
  use Mirror.Web, :channel
  import Guardian.Phoenix.Socket

  import Logger

  def join("retrospectives:" <> retrospective_id, %{"token" => token}, socket) do
    case sign_in(socket, token) do
      {:ok, authed_socket, _guardian_params} ->
        {:ok, %{message: "Joined"}, authed_socket}
      {:error, reason} ->
        {:error, :authentication_required}
    end
  end

  def join(room, _, socket) do
    {:error, :authentication_required}
  end

  def handle_in("ping", %{}, socket) do
    Logger.warn "test"
   broadcast! socket, "ping", %{body: "body"}
   {:noreply, socket}
 end

 def handle_out("ping", payload, socket) do
   push socket, "ping", payload
   {:noreply, socket}
 end


  def handle_info(:ping, socket) do
    Logger.warn "test"
    user = current_resource(socket)
    broadcast(socket, "pong", %{message: "pong", from: user.email})
    {:noreply, socket}
  end
end
