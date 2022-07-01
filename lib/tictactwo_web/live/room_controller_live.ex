defmodule TictactwoWeb.RoomControllerLive do
  # https://elixirforum.com/t/can-we-import-types-and-guards-from-another-module/23737/3
  @type player() :: :blue | :orange
  @type gobbler_name() :: :xl | :large | :medium | :small | :xs | :premie
  @type gobbler() :: %{
          name: gobbler_name(),
          status: gobbler_status()
        }
  @type cell() :: %{
          coords: coords(),
          gobblers: [{player(), gobbler_name()}]
        }
  @type row :: pos_integer()
  @type col :: pos_integer()
  @type coords :: {row(), col()}
  @type gobbler_status :: :not_selected | :selected | {:played, coords()}
  @type selected_gobbler ::
          nil
          | %{
              name: gobbler(),
              played?: coords() | nil
            }

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
      socket
      |> update_gobbler_status(payload.gobbler)

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

  def handle_info(%{event: "gobbler-played", payload: payload}, socket) do
    player = socket.assigns.player_turn

    socket =
      socket
      |> assign(player, payload.gobblers)
      |> assign(
        cells: payload.cells,
        selected_gobbler: nil,
        player_turn: toggle_player_turn(player)
      )

    {:noreply, socket}
  end

  def render(assigns) do
    TictactwoWeb.RoomView.render("show.html", assigns)
  end

  def handle_event("select-gobbler", %{"gobbler" => gobbler, "row" => row, "col" => col}, socket) do
    gobbler = String.to_atom(gobbler)
    row = String.to_integer(row)
    col = String.to_integer(col)

    selected_gobbler = %{
      name: gobbler,
      played?: {row, col}
    }

    updated_cells =
      socket
      |> pop_first_gobbler({row, col})

    socket =
      assign(socket,
        selected_gobbler: selected_gobbler,
        cells: updated_cells
      )

    socket =
      socket
      |> update_gobbler_status(gobbler)

    TictactwoWeb.Endpoint.broadcast(opponent_topic(socket), "gobbler-selected", %{
      gobbler: selected_gobbler
    })

    {:noreply, socket}
  end

  def handle_event("select-gobbler", %{"gobbler" => gobbler}, socket) do
    gobbler = String.to_atom(gobbler)

    selected_gobbler = %{
      name: gobbler,
      played?: nil
    }

    socket =
      assign(socket,
        selected_gobbler: selected_gobbler
      )

    socket =
      socket
      |> update_gobbler_status(gobbler)

    TictactwoWeb.Endpoint.broadcast(opponent_topic(socket), "gobbler-selected", %{
      gobbler: selected_gobbler
    })

    {:noreply, socket}
  end

  def handle_event("deselect-gobbler", %{"gobbler" => gobbler}, socket) do
    gobbler = String.to_atom(gobbler)
    selected_gobbler = socket.assigns.selected_gobbler
    player = socket.assigns.player_turn

    case selected_gobbler.played? do
      {row, col} ->
        updated_cells =
          socket
          |> push_first_gobbler({row, col}, {player, selected_gobbler.name})

        socket =
          assign(socket,
            selected_gobbler: nil,
            cells: updated_cells
          )

        socket =
          socket
          |> update_gobbler_status(gobbler, :not_selected)

        TictactwoWeb.Endpoint.broadcast(opponent_topic(socket), "gobbler-deselected", %{
          gobbler: gobbler
        })

        {:noreply, socket}

      nil ->
        socket = assign(socket, selected_gobbler: nil)

        socket =
          socket
          |> update_gobbler_status(gobbler, :not_selected)

        TictactwoWeb.Endpoint.broadcast(opponent_topic(socket), "gobbler-deselected", %{
          gobbler: gobbler
        })

        {:noreply, socket}
    end
  end

  def handle_event("play-gobbler", %{"row" => row, "col" => col}, socket) do
    row = String.to_integer(row)
    col = String.to_integer(col)

    player = socket.assigns.player_turn
    selected_gobbler = socket.assigns.selected_gobbler

    updated_cells =
      socket
      |> push_first_gobbler({row, col}, {player, selected_gobbler.name})

    updated_gobblers =
      socket.assigns[player]
      |> Map.update!(:gobblers, &set_gobbler_status(&1, selected_gobbler.name, :played))

    new_player = toggle_player_turn(player)

    socket =
      socket
      |> assign(player, updated_gobblers)
      |> assign(
        cells: updated_cells,
        player_turn: new_player,
        selected_gobbler: nil
      )

    TictactwoWeb.Endpoint.broadcast(opponent_topic(socket), "gobbler-played", %{
      cells: updated_cells,
      gobblers: updated_gobblers
    })

    {:noreply, socket}
  end

  # ----------------------------------------------------------------------
  # -------------------- SOCKET FUNCTIONS --------------------------------
  # ----------------------------------------------------------------------
  defp update_gobbler_status(socket, gobbler_name, status \\ :selected) do
    socket
    |> update(socket.assigns.player_turn, fn m ->
      Map.update!(m, :gobblers, &set_gobbler_status(&1, gobbler_name, status))
    end)
  end

  def pop_first_gobbler(socket, {row, col}) do
    socket.assigns.cells
    |> Enum.map(fn cell ->
      case cell.coords do
        {^row, ^col} -> Map.update!(cell, :gobblers, fn [_first | rest] -> rest end)
        _ -> cell
      end
    end)
  end

  def push_first_gobbler(socket, {row, col}, {_player, _gobbler_name} = gobbler) do
    socket.assigns.cells
    |> Enum.map(fn cell ->
      case cell.coords do
        {^row, ^col} -> Map.update!(cell, :gobblers, fn existing -> [gobbler | existing] end)
        _ -> cell
      end
    end)
  end

  # ----------------------------------------------------------------------
  defp gobblers() do
    [:xl, :large, :medium, :small, :xs, :premie]
    |> Enum.map(&%{name: &1, status: :not_selected})
  end

  defp gen_empty_cell(row, col) do
    %{coords: {row, col}, gobblers: []}
  end

  defp gen_empty_cells() do
    Enum.flat_map(0..2, fn row ->
      Enum.map(0..2, fn col ->
        gen_empty_cell(row, col)
      end)
    end)
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

  defp toggle_player_turn(:blue), do: :orange
  defp toggle_player_turn(:orange), do: :blue

  defp set_gobbler_status(gobblers, gobbler, status \\ :selected) do
    for g <- gobblers do
      case g.name == gobbler do
        true -> %{name: g.name, status: status}
        false -> g
      end
    end
  end
end
