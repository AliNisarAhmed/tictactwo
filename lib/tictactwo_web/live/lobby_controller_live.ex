defmodule TictactwoWeb.LobbyControllerLive do
  use TictactwoWeb, :live_view

  @type status() :: :challenge_sent | nil

  alias Tictactwo.Presence

  @lobby_topic "rooms:lobby"
  @events_topic "event_bus:"

  def mount(_params, session, socket) do
    send(self(), :after_join)

    {:ok,
     assign(socket,
       loading: true,
       current_user: session["current_user"],
       users: %{},
       challenges: []
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

  def handle_event("accept-challenge", %{"challenger" => challenger}, socket) do
    TictactwoWeb.Endpoint.broadcast(@events_topic <> challenger, "challenge-accepted", %{
      userid: socket.assigns.current_user.id
    })

    {:noreply, socket}
  end

  # -------- Handle Info -----------

  def handle_info(:after_join, socket) do
    TictactwoWeb.Endpoint.subscribe(@lobby_topic)
    TictactwoWeb.Endpoint.subscribe(@events_topic <> socket.assigns.current_user.id)

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

  def handle_info(%{event: "challenge-accepted", payload: %{userid: userid}}, socket) do
    # Create a room
    roomid = "abcdefghijk"

    # redirect owner to the room

    socket = push_redirect(socket, to: "/rooms/#{roomid}")

    # send the other player an event to join the room
    TictactwoWeb.Endpoint.broadcast(@events_topic <> userid, "room-created", %{
      roomid: roomid
    })

    {:noreply, socket}
  end

    def handle_info(%{event: "room-created", payload: %{roomid: roomid}}, socket) do

    socket = push_redirect(socket, to: "/rooms/#{roomid}")

    {:noreply, socket}
  end

  def render(assigns) do
    TictactwoWeb.LobbyView.render("show.html", assigns)
  end

  @spec toggle_status(status()) :: status()
  defp toggle_status(:challenge_sent), do: nil
  defp toggle_status(_), do: :challenge_sent
end