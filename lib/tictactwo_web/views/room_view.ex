defmodule TictactwoWeb.RoomView do
  use TictactwoWeb, :view

  use Tictactwo.Types

  alias Tictactwo.Games
  alias TictactwoWeb.Components.GameStatus
  alias TictactwoWeb.Components.Board
  alias TictactwoWeb.Components.Gobbler

  @spec my_turn?(game :: game(), user_type:: viewer_type())::boolean()
  def my_turn?(_, :spectator), do: false
  def my_turn?(game, user_type) do 
    game.player_turn == user_type
  end

  def winning_player(%{status: :blue_won}) do
    "blue"
  end

  def winning_player(%{status: :orange_won}) do
    "orange"
  end

  defp gobbler_class(color) do
    "w-20 h-10 py-2 px-4 bg-#{color |> to_string()}-500"
  end

  def not_selected_gobblers(game, :spectator) do
    not_selected_gobblers(game, :blue)
  end
  def not_selected_gobblers(game, user_type) do 
    game 
    |> Map.get(user_type)
    |> Enum.filter(&(&1.status == :not_selected))
  end

  def played_gobbler_text(gobblers) do
    gobblers
    |> List.first({" ", " "})
    |> elem(1)
  end

  def played_gobbler_color(gobblers) do
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

  def first_gobbler_name(gobblers) do
    gobblers
    |> List.first()
    |> then(fn
      {_, name} -> name
      _ -> " "
    end)
  end

  def first_gobbler_selected?(gobblers, selected_gobbler, player_turn) do
    gobblers
    |> List.first()
    |> then(fn
      {^player_turn, name} when name == selected_gobbler.name ->
        true

      _ ->
        false
    end)
  end

  def get_current_user_color(:orange), do: "orange"
  def get_current_user_color(_), do: "blue"

  def toggle_player_turn(:blue), do: :orange
  def toggle_player_turn(_), do: :blue

  def set_cursor(game, gobblers) do
    case Games.move_allowed?(game, gobblers) do
      true -> "cursor-pointer"
      false -> "cursor-not-allowed"
    end
  end

  def hide_last_gobbler(game, cell_coords) do
    selected_gobbler = game.selected_gobbler

    if not is_nil(selected_gobbler.played?) and selected_gobbler.played? == cell_coords do
      "hidden"
    else
      ""
    end
  end

  @spec is_player?(viewer_type) :: boolean()
  def is_player?(:spectator), do: false 
  def is_player?(_), do: true
end
