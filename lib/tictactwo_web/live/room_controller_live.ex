defmodule TictactwoWeb.RoomControllerLive do
  @type player() :: :blue | :orange
  @type gobbler_name() :: :xl | :large | :medium | :small | :xs | :premie
  @type gobbler() :: %{
          name: gobbler_name(),
          status: gobbler_status()
        }
  @type cell() :: %{
          occupied_by: player() | nil,
          pieces: [gobbler()] | nil
        }
  @type row :: pos_integer()
  @type col :: pos_integer()
  @type coords :: {row(), col()}
  @type gobbler_status :: :not_selected | :selected | {:played, coords()}

  @room_topic "rooms:"

  use TictactwoWeb, :live_view

  def mount(_params, session, socket) do
    send(self(), :after_join)

    socket =
      socket
      |> assign(
        roomid: session["roomid"],
        current_user: session["current_user"],
        game: %{
          "fletcher2033" => "blue",
          "lacy_crist" => "orange"
        },
        cells: gen_empty_cells(),
        player_turn: :blue,
        selected_gobbler: nil,
        blue: %{
          gobblers: gobblers(),
          played: []
        },
        orange: %{
          gobblers: gobblers(),
          played: []
        }
      )

    {:ok, assign(socket, roomid: session["roomid"])}
  end

  def handle_info(:after_join, socket) do
    TictactwoWeb.Endpoint.subscribe(topic(socket))
    {:noreply, socket}
  end

  def handle_info(%{event: "gobbler-selected", payload: payload}, socket) do
    socket =
      assign(socket,
        selected_gobbler: payload.gobbler
      )

    socket =
      update(socket, socket.assigns.player_turn, fn m ->
        Map.update!(m, :gobblers, &set_gobbler_status(&1, payload.gobbler))
      end)

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

  def render(assigns) do
    TictactwoWeb.RoomView.render("show.html", assigns)
  end

  def handle_event("select-gobbler", %{"gobbler" => gobbler}, socket) do
    gobbler = String.to_atom(gobbler)

    socket =
      assign(socket,
        selected_gobbler: gobbler
      )

    socket =
      update(socket, socket.assigns.player_turn, fn m ->
        Map.update!(m, :gobblers, &set_gobbler_status(&1, gobbler))
      end)

    TictactwoWeb.Endpoint.broadcast(opponent_topic(socket), "gobbler-selected", %{
      gobbler: gobbler
    })

    {:noreply, socket}
  end

  def handle_event("deselect-gobbler", %{"gobbler" => gobbler}, socket) do
    gobbler = String.to_atom(gobbler)
    socket = assign(socket, selected_gobbler: nil)

    socket =
      update(socket, socket.assigns.player_turn, fn m ->
        Map.update!(m, :gobblers, &set_gobbler_status(&1, gobbler, :not_selected))
      end)

    TictactwoWeb.Endpoint.broadcast(opponent_topic(socket), "gobbler-deselected", %{
      gobbler: gobbler
    })

    {:noreply, socket}
  end

  defp gobblers() do
    [:xl, :large, :medium, :small, :xs, :premie]
    |> Enum.map(&%{name: &1, status: :not_selected})
  end

  defp gen_empty_cell(row, col) do
    %{
      coords: {row, col},
      gobblers: []
    }
  end

  defp gen_empty_cells() do
    for row <- 0..2 do
      for col <- 0..2 do
        gen_empty_cell(row, col)
      end
    end
  end

  defp topic(socket) do
    @room_topic <>
      "#{socket.assigns.roomid}:" <>
      to_string(socket.assigns.game[socket.assigns.current_user.username])
  end

  defp opponent_topic(socket) do
    @room_topic <>
      "#{socket.assigns.roomid}:" <>
      (socket.assigns.game[socket.assigns.current_user.username]
       |> to_string()
       |> toggle_color())
  end

  defp toggle_color("blue"), do: "orange"
  defp toggle_color("orange"), do: "blue"

  defp set_gobbler_status(gobblers, gobbler, status \\ :selected) do
    for g <- gobblers do
      case g.name == gobbler do
        true -> %{name: g.name, status: status}
        false -> g
      end
    end
  end
end
