defmodule TictactwoWeb.RoomController do
  use TictactwoWeb, :controller

  alias Phoenix.LiveView
  alias TictactwoWeb.RoomControllerLive

  def show(conn, params) do
    current_user = get_session(conn, "current_user")

    # TODO: fetch game from database

    LiveView.Controller.live_render(
      conn,
      RoomControllerLive,
      session: %{
        "roomid" => params["roomid"],
        "current_user" => current_user
      }
    )
  end
end
