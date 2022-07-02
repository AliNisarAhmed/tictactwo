defmodule TictactwoWeb.RoomView do
  use TictactwoWeb, :view

  defp my_turn?(current_user, game) do
    current_user.username == game[game.player_turn].username
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

  def can_select?(gobblers, player) do
    gobblers
    |> List.first()
    |> then(fn
      {^player, _name} -> true
      _ -> false
    end)
  end

  defp first_gobbler_name(gobblers) do
    gobblers
    |> List.first()
    |> then(fn
      {_, name} -> name
      _ -> " "
    end)
  end

  defp first_gobbler_selected?(gobblers, selected_gobbler, player_turn) do
    gobblers
    |> List.first()
    |> then(fn
      {^player_turn, name} when name == selected_gobbler.name ->
        true

      _ ->
        false
    end)
  end
end
