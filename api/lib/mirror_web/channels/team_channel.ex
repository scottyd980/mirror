defmodule Mirror.TeamChannel do
  use MirrorWeb, :channel
  import Guardian.Phoenix.Socket
  alias Mirror.Retrospectives
  alias Mirror.Teams
  alias Mirror.Teams.Team

  alias Mirror.Helpers.User

  #TODO: NOT SURE IF EVERYTHING IS AS PROTECTED AS IT NEEDS TO BE
  def join("team:" <> team_id, %{"token" => token}, socket) do
    case authenticate(socket, Mirror.Guardian, token) do
      {:ok, authed_socket} ->
        {:ok, %{message: "Joined"}, authed_socket}
      {:error, reason} ->
        {:error, :authentication_required}
    end
  end

  def join(room, _, socket) do
    {:error, :authentication_required}
  end

  def handle_in("check_retrospective_in_progress", %{}, socket) do
    {user, team} = get_basic_data(socket)

    case User.user_is_team_member?(user, team) do
      true ->
        {retro_in_progress, retro} = Team.check_retrospective_in_progress(team)
        handle_retro_in_progress_response(socket, retro_in_progress, retro)
    end

    {:noreply, socket}
  end

  def handle_in("join_retrospective_in_progress", %{}, socket) do
    {user, team} = get_basic_data(socket)

    {retro_in_progress, retro} = Team.check_retrospective_in_progress(team)

    Retrospectives.create_participant(%{user_id: user.id, retrospective_id: List.first(retro).id})

    broadcast! socket, "joined_retrospective", %{user_id: user.id, retrospective_id: List.first(retro).id}

    {:noreply, socket}

  end

  defp get_basic_data(socket) do
    user = current_resource(socket)
    "team:" <> team_id = socket.topic
    team = Teams.get_team!(team_id)

    {user, team}
  end

  defp handle_retro_in_progress_response(socket, retro_in_progress, retro) do
    case retro_in_progress do
      true ->
        broadcast! socket, "retrospective_in_progress", %{retrospective_in_progress: retro_in_progress, retrospective_id: List.first(retro).id}
      _ ->
        broadcast! socket, "retrospective_in_progress", %{retrospective_in_progress: false}
    end
  end

end
