defmodule TictactwoWeb.RoomControllerLive do
  @room_topic "rooms:"

  use TictactwoWeb, :live_view

  alias Tictactwo.Presence
  alias Tictactwo.Games

  def mount(params, session, socket) do
    if connected?(socket), do: send(self(), :after_join)

    game_slug = params["game_slug"]
    current_user = session["current_user"]

    game = Games.get_game_by_slug!(game_slug)

    user_type = Games.get_user_type(game, current_user)

    socket =
      socket
      |> assign(
        game_slug: game_slug,
        current_user: current_user,
        user_type: user_type,
        game: game
      )

    {:ok, socket}
  end

  def terminate(reason, _socket) do
    # TODO: Handle users leaving the room 
    # Close the game once both players leave
  end

  def handle_info(:after_join, socket) do
    TictactwoWeb.Endpoint.subscribe(topic(socket))

    Presence.track(
      self(),
      topic(socket),
      socket.assigns.current_user.id,
      %{
        id: socket.assigns.current_user.id,
        username: socket.assigns.current_user.username
      }
    )

    # Presence.track(socket, topic(socket), %{})

    {:noreply, socket}
  end

  # presence diff
  def handle_info(%{event: "presence_diff", payload: payload}, %{assigns: _assigns} = socket) do
    {:noreply, socket}
  end

  # gobbler-selected: Already played Gobbler
  def handle_info(
        %{
          event: "gobbler-selected",
          payload: %{
            gobbler_name: gobbler_name_str,
            row: row,
            col: col
          }
        },
        socket
      ) do
    gobbler_name = gobbler_name_str |> String.to_atom()
    row = String.to_integer(row)
    col = String.to_integer(col)

    socket =
      socket
      |> update(:game, &Games.select_already_played_gobbler(&1, gobbler_name, {row, col}))

    {:noreply, socket}
  end

  # gobbler-selected: Unplayed Gobbler
  def handle_info(
        %{
          event: "gobbler-selected",
          payload: %{
            gobbler_name: gobbler_name_str
          }
        },
        socket
      ) do
    gobbler_name = gobbler_name_str |> String.to_atom()

    socket =
      socket
      |> update(:game, &Games.select_unplayed_gobbler(&1, gobbler_name))

    {:noreply, socket}
  end

  # gobbler-deselected:
  def handle_info(%{event: "gobbler-deselected", payload: _payload}, socket) do
    socket = assign(socket, selected_gobbler: nil)

    socket =
      socket
      |> update(:game, &Games.deselect_gobbler/1)

    {:noreply, socket}
  end

  # gobbler-played
  def handle_info(%{event: "gobbler-played", payload: %{row: row, col: col}}, socket) do
    row = String.to_integer(row)
    col = String.to_integer(col)

    updated_game =
      socket.assigns.game
      |> Games.play_gobbler({row, col})

    socket =
      socket
      |> assign(:game, updated_game)

    {:noreply, socket}
  end

  # offer rematch
  def handle_info(%{event: "offer-rematch", payload: %{username: username, color: color}}, socket) do
    updated_game =
      socket.assigns.game
      |> Games.rematch_offered(username, color)

    socket =
      socket
      |> assign(:game, updated_game)

    {:noreply, socket}
  end

  # rematch-accepted
  def handle_info(%{event: "rematch-accepted", payload: %{new_game_slug: new_game_slug}}, socket) do
    IO.puts("REMATCH ACCEPTED")

    {:noreply, push_redirect(socket, to: "/rooms/#{new_game_slug}", replace: true)}
  end

  # abort-game
  def handle_info(%{event: "abort-game", payload: %{username: username}}, socket) do
    updated_game = Games.abort_game(socket.assigns.game, username)

    socket =
      socket
      |> assign(:game, updated_game)

    {:noreply, socket}
  end

  def render(assigns) do
    TictactwoWeb.RoomView.render("show.html", assigns)
  end

  # Broadcast event for selecting already played Gobbler
  def handle_event("select-gobbler", %{"gobbler" => gobbler, "row" => row, "col" => col}, socket) do
    TictactwoWeb.Endpoint.broadcast(topic(socket), "gobbler-selected", %{
      gobbler_name: gobbler,
      row: row,
      col: col
    })

    {:noreply, socket}
  end

  # Broadcast event for selecting unselected Gobbler
  def handle_event("select-gobbler", %{"gobbler" => gobbler}, socket) do
    TictactwoWeb.Endpoint.broadcast(topic(socket), "gobbler-selected", %{
      gobbler_name: gobbler
    })

    {:noreply, socket}
  end

  # Broadcast event: deselect Gobbler
  def handle_event("deselect-gobbler", _, socket) do
    TictactwoWeb.Endpoint.broadcast(topic(socket), "gobbler-deselected", %{})

    {:noreply, socket}
  end

  # Broadcast event: play Gobbler
  def handle_event("play-gobbler", %{"row" => row, "col" => col}, socket) do
    TictactwoWeb.Endpoint.broadcast(topic(socket), "gobbler-played", %{
      row: row,
      col: col
    })

    {:noreply, socket}
  end

  # Broadcast event: offer rematch
  def handle_event(
        "offer-rematch" = event,
        %{"username" => username, "color" => color} = _payload,
        socket
      ) do
    TictactwoWeb.Endpoint.broadcast(topic(socket), event, %{
      username: username,
      color: color
    })

    {:noreply, socket}
  end

  # Broadcast event - rematch accepted
  def handle_event("rematch-accepted" = event, _payload, socket) do
    new_game_slug = Games.rematch_accepted(socket.assigns.game)

    TictactwoWeb.Endpoint.broadcast(topic(socket), event, %{
      new_game_slug: new_game_slug
    })

    {:noreply, socket}
  end

  def handle_event("abort-game" = event, %{"username" => username}, socket) do
    TictactwoWeb.Endpoint.broadcast(topic(socket), event, %{
      username: username
    })

    {:noreply, push_redirect(socket, to: "/lobby")}
  end

  def handle_event("back-to-lobby", _payload, socket) do
    {:noreply, push_redirect(socket, to: "/lobby")}
  end

  # ----------------------------------------------------------------------

  defp topic(socket) do
    @room_topic <> "#{socket.assigns.game_slug}"
  end
end
