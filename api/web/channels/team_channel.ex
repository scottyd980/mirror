defmodule Mirror.TeamChannel do
  use Mirror.Web, :channel
  import Guardian.Phoenix.Socket

  alias Mirror.{UserHelper, Team, Retrospective, RetrospectiveUser}

  def join("team:" <> team_id, %{"token" => token}, socket) do
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

  def handle_in("check_retrospective_in_progress", %{}, socket) do
    {user, team} = get_basic_data(socket)

    case UserHelper.user_is_team_member?(user, team) do
      true ->
        {retro_in_progress, retro} = Team.check_retrospective_in_progress(team)
        handle_retro_in_progress_response(socket, retro_in_progress, retro)
    end

    {:noreply, socket}
  end

  def handle_in("join_retrospective_in_progress", %{}, socket) do

    {user, team} = get_basic_data(socket)

    {retro_in_progress, retro} = Team.check_retrospective_in_progress(team)

    %RetrospectiveUser{}
    |> RetrospectiveUser.changeset(%{user_id: user.id, retrospective_id: List.first(retro).id})
    |> Repo.insert

    broadcast! socket, "joined_retrospective", %{user_id: user.id, retrospective_id: List.first(retro).id}

    {:noreply, socket}

  end

  defp get_basic_data(socket) do
    user = current_resource(socket)
    "team:" <> team_id = socket.topic
    team = Repo.get!(Team, team_id)

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
