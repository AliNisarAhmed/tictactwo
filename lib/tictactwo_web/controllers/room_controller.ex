defmodule TictactwoWeb.RoomController do
  use TictactwoWeb, :controller

  alias Phoenix.LiveView
  alias TictactwoWeb.RoomControllerLive
  alias Tictactwo.Games

  def show(conn, %{"game_slug" => game_slug}) do
    current_user = get_session(conn, "current_user") |> IO.inspect(label: "CURRENT_USER")

    {blue_username, orange_username} =
      Games.fetch_players(game_slug)

    case current_user do
      %{"username" => ^blue_username, "id" => _id} ->
        render_game(conn, game_slug, current_user, :blue)

      %{"username" => ^orange_username, "id" => _id} ->
        render_game(conn, game_slug, current_user, :orange)

      _ ->
        render_game(conn, game_slug, current_user, :spectator)
    end
  end

  defp render_game(conn, game_slug, current_user, user_type) do
    LiveView.Controller.live_render(
      conn,
      RoomControllerLive,
      session: %{
        "game_slug" => game_slug,
        "current_user" => current_user,
        "user_type" => user_type
      }
    )
  end
end
