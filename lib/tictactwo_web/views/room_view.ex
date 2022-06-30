defmodule TictactwoWeb.RoomView do
  use TictactwoWeb, :view

  defp my_turn?(current_user, game, player_turn) do
    game[current_user.username] == to_string(player_turn)
  end

  defp show_coords({row, col}) do
    "(#{row}, #{col})"
  end

  defp gobbler_class(player_turn, color) do
    "w-20 h-10 py-2 px-4 #{bg_color(player_turn, color)}"
  end

  defp bg_color(player_turn, color) do
    if player_turn == color do
      "bg-#{color |> to_string()}-500"
    else
      "bg-#{color |> to_string()}-300"
    end
  end
end
