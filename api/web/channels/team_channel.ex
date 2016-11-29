defmodule Mirror.TeamChannel do
  use Mirror.Web, :channel
  import Guardian.Phoenix.Socket

  alias Mirror.UserHelper
  alias Mirror.Team
  alias Mirror.Retrospective

  def join("team:" <> team_id, %{"token" => token}, socket) do
    case sign_in(socket, token) do
      {:ok, authed_socket, _guardian_params} ->
        team = Repo.get!(Team, team_id)
        case UserHelper.user_is_team_member?(current_resource(authed_socket), team) do
          true ->
            retro_in_progress = Retrospective.check_retrospective_in_progress(team)
            {:ok, %{message: "Joined", retro_in_progress: retro_in_progress}, authed_socket}
          _ ->
            {:error, 401}
        end
      {:error, reason} ->
        {:error, :authentication_required}
    end
  end

  def join(room, _, socket) do
    {:error, :authentication_required}
  end

  def handle_in("ping", %{}, socket) do
    user = current_resource(socket)
    broadcast! socket, "ping", %{body: user.email}
    {:noreply, socket}
  end

  def handle_out("ping", payload, socket) do
    push socket, "ping", payload
    {:noreply, socket}
  end

  def handle_in("inProgress", %{}, socket) do
    user = current_resource(socket)
    broadcast! socket, "inProgress", %{}
    {:noreply, socket}
  end

  def handle_out("inProgress", payload, socket) do
    push socket, "inProgress", payload
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    user = current_resource(socket)
    broadcast(socket, "pong", %{message: "pong", from: user.email})
    {:noreply, socket}
  end


end
