defmodule TictactwoWeb.LobbyControllerLive do
  use TictactwoWeb, :live_view

  @type status() :: :challenge_sent | nil

  alias Tictactwo.Presence
  alias Tictactwo.Games

  @lobby_topic "rooms:lobby"
  @events_topic "event_bus:"

  def mount(_params, session, socket) do
    send(self(), :after_join)

    {:ok,
     assign(socket,
       loading: true,
       current_user: session["current_user"],
       users: %{},
       challenges: [],
       current_games: []
     )}
  end

  def handle_event("challenge-user", %{"userid" => userid}, socket) do
    users =
      socket.assigns.users
      |> Map.update!(userid, fn prev ->
        prev
        |> Map.update!(:status, &toggle_status/1)
      end)

    TictactwoWeb.Endpoint.broadcast(@events_topic <> userid, "challenge-received", %{
      userid: userid,
      challenger: socket.assigns.current_user
    })

    {:noreply, assign(socket, users: users)}
  end

  def handle_event(
        "accept-challenge",
        %{"challenger-username" => challenger_username, "challenger-id" => challenger_id},
        socket
      ) do
    game_slug = Games.new_game(:blue, socket.assigns.current_user.username, challenger_username)

    TictactwoWeb.Endpoint.broadcast(@events_topic <> challenger_id, "challenge-accepted", %{
      userid: socket.assigns.current_user.id,
      game_slug: game_slug
    })

    {:noreply, socket}
  end

  # -------- Handle Info -----------

  def handle_info(:after_join, socket) do
    TictactwoWeb.Endpoint.subscribe(@lobby_topic)
    TictactwoWeb.Endpoint.subscribe(@events_topic <> socket.assigns.current_user.id)
    TictactwoWeb.Endpoint.subscribe(Tictactwo.CurrentGames.topic())

    Presence.track(
      self(),
      @lobby_topic,
      socket.assigns.current_user.id,
      %{
        id: socket.assigns.current_user.id,
        username: socket.assigns.current_user.username
      }
    )

    {:noreply,
     assign(socket,
       loading: false
     )}
  end

  def handle_info(
        %{event: "presence_diff", payload: _payload},
        %{assigns: _assigns} = socket
      ) do
    users = Presence.list_presences(@lobby_topic)

    {:noreply, assign(socket, users: users)}
  end

  def handle_info(%{event: "challenge-received", payload: payload}, socket) do
    {:noreply, assign(socket, challenges: [payload.challenger | socket.assigns.challenges])}
  end

  def handle_info(
        %{event: "challenge-accepted", payload: %{userid: userid, game_slug: game_slug}},
        socket
      ) do
    # redirect owner to the game room
    socket = push_redirect(socket, to: "/rooms/#{game_slug}")

    # send the other player an event to join the room
    TictactwoWeb.Endpoint.broadcast(@events_topic <> userid, "room-created", %{
      game_slug: game_slug
    })

    {:noreply, socket}
  end

  def handle_info(%{event: "room-created", payload: %{game_slug: game_slug}}, socket) do
    socket = push_redirect(socket, to: "/rooms/#{game_slug}")

    {:noreply, socket}
  end

  # Handle current games change event
  def handle_info(%{event: "current-games-updated", payload: payload}, socket) do
    socket =
      socket
      |> assign(:current_games, payload)

    {:noreply, socket}
  end

  def render(assigns) do
    TictactwoWeb.LobbyView.render("show.html", assigns)
  end

  @spec toggle_status(status()) :: status()
  defp toggle_status(:challenge_sent), do: nil
  defp toggle_status(_), do: :challenge_sent
end
