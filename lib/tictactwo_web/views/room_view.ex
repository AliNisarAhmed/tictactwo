defmodule TictactwoWeb.RoomView do
  use TictactwoWeb, :view

  alias Tictactwo.Games
  alias TictactwoWeb.Components.GameStatus

  def my_turn?(current_user, game) do
    username = Map.get(game, game.player_turn)
    current_user.username == username
  end

  def winning_player(%{status: {:won, player}}) do
    player |> to_string()
  end

  defp gobbler_class(color) do
    "w-20 h-10 py-2 px-4 bg-#{color |> to_string()}-500"
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

  defp get_current_user_color(current_user, game) do
    if my_turn?(current_user, game) do
      game.player_turn |> to_string
    else
      game.player_turn
      |> toggle_player_turn()
      |> to_string()
    end
  end

  defp toggle_player_turn(:blue), do: :orange
  defp toggle_player_turn(:orange), do: :blue

  defp set_cursor(game, gobblers) do
    case Games.move_allowed?(game, gobblers) do
      true -> "cursor-pointer"
      false -> "cursor-not-allowed"
    end
  end

  defp hide_last_gobbler(game, cell_coords) do
    selected_gobbler = game.selected_gobbler

    if not is_nil(selected_gobbler.played?) and selected_gobbler.played? == cell_coords do
      "hidden"
    else
      ""
    end
  end
end
