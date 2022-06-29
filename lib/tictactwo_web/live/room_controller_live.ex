defmodule TictactwoWeb.RoomControllerLive do

  @type player() :: :blue | :orange
  @type gobbler() :: :xl | :large | :medium | :small | :xs | :premie
  @type cell() :: %{
    occupied_by: player() | nil,
    pieces: [gobbler()] | nil
  }

  use TictactwoWeb, :live_view

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(
        roomid: session["roomid"],
        cells: [1, 2, 3, 4, 5, 6, 7, 8, 9],
        player_turn: :blue,
        selected_gobbler: nil,
        blue_gobblers_played: [],
        blue_gobblers: gobblers(),
        orange_gobblers_played: [],
        orange_gobblers: gobblers()
      )
    {:ok, assign(socket, roomid: session["roomid"])}
  end

  def render(assigns) do
    TictactwoWeb.RoomView.render("show.html", assigns)
  end

  defp gobblers() do
    [:xl, :large, :medium, :small, :xs, :premie]
  end
end
