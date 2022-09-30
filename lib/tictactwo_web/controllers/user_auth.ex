defmodule TictactwoWeb.UserAuth do
  import Plug.Conn

  alias Tictactwo.Games

  def populate_user_info(%{path_params: %{"game_slug" => game_slug}} = conn, _opts) do
    current_user = get_session(conn, "current_user")

    {blue_username, orange_username} = Games.fetch_players(game_slug)

    case current_user do
      %{username: ^blue_username, id: _id} ->
        IO.puts("BLUE JOINED")

        conn
        |> put_session(:user_type, :blue)
        |> put_session(:current_user, current_user)

      %{username: ^orange_username, id: _id} ->
        IO.puts("ORANGE JOINED")

        conn
        |> put_session(:user_type, :orange)
        |> put_session(:current_user, current_user)

      _ ->
        IO.puts("SPECTATOR JOINED")

        conn
        |> put_session(:user_type, :spectator)
        |> put_session(:current_user, current_user)
    end
  end
end
