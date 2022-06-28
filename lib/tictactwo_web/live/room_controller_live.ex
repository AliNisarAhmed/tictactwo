defmodule TictactwoWeb.RoomControllerLive do
  use TictactwoWeb, :live_view

  def mount(_params, session, socket) do
    {:ok, assign(socket, roomid: session["roomid"])}
  end

  def render(assigns) do
    TictactwoWeb.RoomView.render("show.html", assigns)
  end
end
