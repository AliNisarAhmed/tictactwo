defmodule TictactwoWeb.RoomController do
  use TictactwoWeb, :controller

  alias Phoenix.LiveView
  alias TictactwoWeb.RoomControllerLive

  def show(conn, params) do
    LiveView.Controller.live_render(
      conn,
      RoomControllerLive,
      session: %{
        "roomid" => params["roomid"]
      }
    )
  end
end
