defmodule TictactwoWeb.RoomControllerLive do
  @room_topic "rooms:"

  use TictactwoWeb, :live_view

  alias Tictactwo.Games

  def mount(_params, session, socket) do
    send(self(), :after_join)

    socket =
      socket
      |> assign(
        roomid: session["roomid"],
        current_user: session["current_user"],
        game: Games.new_game()
      )

    {:ok, assign(socket, roomid: session["roomid"])}
  end

  def handle_info(:after_join, socket) do
    TictactwoWeb.Endpoint.subscribe(topic(socket))
    {:noreply, socket}
  end

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

    selected_gobbler = %{
      name: gobbler_name,
      played?: {row, col}
    }

    socket =
      socket
      |> remove_selected_gobbler_from_cells({row, col})
      |> set_selected_gobbler(selected_gobbler)
      |> update_gobbler_status(gobbler_name, :selected)

    {:noreply, socket}
  end

  def handle_info(
        %{
          event: "gobbler-selected",
          payload: %{
            gobbler_name: gobbler_name_str
          }
        },
        socket
      ) do
    name = gobbler_name_str |> String.to_atom()
    selected_gobbler = %{name: name, played?: nil}

    socket =
      socket
      |> set_selected_gobbler(selected_gobbler)
      |> update_gobbler_status(name, :selected)

    {:noreply, socket}
  end

  def handle_info(%{event: "gobbler-deselected", payload: payload}, socket) do
    socket = assign(socket, selected_gobbler: nil)

    socket =
      update(socket, socket.assigns.player_turn, fn m ->
        Map.update!(m, :gobblers, &set_gobbler_status(&1, payload.gobbler, :not_selected))
      end)

    {:noreply, socket}
  end

  def handle_info(%{event: "gobbler-played", payload: %{row: row, col: col}}, socket) do
    gobbler_name = socket.assigns.game.selected_gobbler.name
    row = String.to_integer(row)
    col = String.to_integer(col)

    socket =
      socket
      |> push_first_gobbler({row, col})
      |> update_gobbler_status(gobbler_name, :played)
      |> set_selected_gobbler(nil)
      |> toggle_player_turn()

    {:noreply, socket}
  end

  def render(assigns) do
    TictactwoWeb.RoomView.render("show.html", assigns)
  end

  def handle_event("select-gobbler", %{"gobbler" => gobbler, "row" => row, "col" => col}, socket) do
    TictactwoWeb.Endpoint.broadcast(topic(socket), "gobbler-selected", %{
      gobbler_name: gobbler,
      row: row,
      col: col
    })

    {:noreply, socket}
  end

  def handle_event("select-gobbler", %{"gobbler" => gobbler}, socket) do
    TictactwoWeb.Endpoint.broadcast(topic(socket), "gobbler-selected", %{
      gobbler_name: gobbler
    })

    {:noreply, socket}
  end

  def handle_event("deselect-gobbler", _, socket) do
    socket =
      socket
      |> deselect_gobbler()

    TictactwoWeb.Endpoint.broadcast(topic(socket), "gobbler-deselected", %{})

    {:noreply, socket}
  end

  def handle_event("play-gobbler", %{"row" => row, "col" => col}, socket) do
    TictactwoWeb.Endpoint.broadcast(topic(socket), "gobbler-played", %{
      row: row,
      col: col
    })

    {:noreply, socket}
  end

  # ----------------------------------------------------------------------
  # -------------------- SOCKET FUNCTIONS --------------------------------
  # ----------------------------------------------------------------------
  defp remove_selected_gobbler_from_cells(socket, coords) do
    socket
    |> update(:game, &Games.pop_first_gobbler(&1, coords))
  end

  defp set_selected_gobbler(socket, selected_gobbler) do
    socket
    |> update(:game, &Games.set_selected_gobbler(&1, selected_gobbler))
  end

  defp update_gobbler_status(socket, gobbler_name, status) do
    socket
    |> update(:game, &Games.update_gobbler_status(&1, gobbler_name, status))
  end

  defp deselect_gobbler(socket) do
    socket
    |> update(:game, &Games.deselect_gobbler(&1))
  end

  defp push_first_gobbler(socket, coords) do
    socket
    |> update(:game, &Games.push_gobbler(&1, coords))
  end

  defp toggle_player_turn(socket) do
    socket
    |> update(:game, &Games.toggle_player_turn/1)
  end

  # ----------------------------------------------------------------------

  defp topic(socket) do
    @room_topic <> "#{socket.assigns.roomid}"
  end

  defp set_gobbler_status(gobblers, gobbler, status) do
    for g <- gobblers do
      case g.name == gobbler do
        true -> %{name: g.name, status: status}
        false -> g
      end
    end
  end
end
