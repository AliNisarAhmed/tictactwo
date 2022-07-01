defmodule TictactwoWeb.RoomView do
  use TictactwoWeb, :view

  defp my_turn?(current_user, game, player_turn) do
    game[current_user.username] == to_string(player_turn)
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

  defp not_selected_gobblers(gobblers) do
    gobblers
    |> Enum.filter(&(&1.status == :not_selected))
  end

  defp played_gobbler_text(gobblers) do
    gobblers
    |> List.first({" ", " "})
    |> elem(1)
  end

  defp played_gobbler_color(gobblers) do
    gobblers
    |> List.first({" ", " "})
    |> elem(0)
    |> to_string()
    |> then(fn color -> "bg-#{color}-500" end)
  end
end
