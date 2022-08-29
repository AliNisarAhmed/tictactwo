defmodule TictactwoWeb.RoomControllerLive do
  @room_topic "rooms:"

  use TictactwoWeb, :live_view

  alias Tictactwo.Games

  def mount(_params, session, socket) do
    send(self(), :after_join)

    game = Games.get_game_by_slug!(session["game_slug"])

    socket =
      socket
      |> assign(
        game_slug: session["game_slug"],
        current_user: session["current_user"],
        game: game
      )

    {:ok, assign(socket, roomid: session["roomid"])}
  end

  def handle_info(:after_join, socket) do
    TictactwoWeb.Endpoint.subscribe(topic(socket))
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

  # ----------------------------------------------------------------------

  defp topic(socket) do
    @room_topic <> "#{socket.assigns.game_slug}"
  end
end
