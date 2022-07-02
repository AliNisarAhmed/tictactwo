defmodule Tictactwo.Games do
  use Tictactwo.Types

  @spec new_game(player()) :: game()
  def new_game(player_turn \\ :blue) do
    %{
      blue: %{
        username: "fletcher2033",
        gobblers: new_gobblers()
      },
      orange: %{
        username: "cortez_jenkins",
        gobblers: new_gobblers()
      },
      cells: gen_empty_cells(),
      player_turn: player_turn,
      selected_gobbler: nil
    }
  end

  @spec new_gobblers() :: [gobbler()]
  defp new_gobblers() do
    [:xl, :large, :medium, :small, :xs, :premie]
    |> Enum.map(&%{name: &1, status: :not_selected})
  end

  @spec gen_empty_cell(row :: pos_integer(), col :: pos_integer()) :: cell()
  defp gen_empty_cell(row, col) do
    %{coords: {row, col}, gobblers: []}
  end

  @spec gen_empty_cells() :: [cell()]
  defp gen_empty_cells() do
    Enum.flat_map(0..2, fn row ->
      Enum.map(0..2, fn col ->
        gen_empty_cell(row, col)
      end)
    end)
  end

  @spec pop_first_gobbler(game :: game(), coords :: coords()) :: game()
  def pop_first_gobbler(game, {row, col}) do
    Map.put(
      game,
      :cells,
      game.cells
      |> Enum.map(fn cell ->
        case cell.coords do
          {^row, ^col} -> Map.update!(cell, :gobblers, fn [_first | rest] -> rest end)
          _ -> cell
        end
      end)
    )
  end

  @spec push_gobbler(game :: game(), coords :: coords()) :: game()
  def push_gobbler(game, {row, col}) do
    Map.put(
      game,
      :cells,
      game.cells
      |> Enum.map(fn cell ->
        case cell.coords do
          {^row, ^col} ->
            Map.update!(cell, :gobblers, fn gs ->
              [{game.player_turn, game.selected_gobbler.name} | gs]
            end)

          _ ->
            cell
        end
      end)
    )
  end

  @spec set_selected_gobbler(game :: game(), selected_gobbler :: selected_gobbler) :: game()
  def set_selected_gobbler(game, selected_gobbler) do
    game
    |> Map.put(:selected_gobbler, selected_gobbler)
  end

  @spec update_gobbler_status(
          game :: game(),
          gobbler_name :: gobbler(),
          status :: gobbler_status()
        ) :: game()
  def update_gobbler_status(game, gobbler_name, status) do
    game
    |> Map.update!(
      game.player_turn,
      fn player ->
        %{player | gobblers: set_gobbler_status(player.gobblers, gobbler_name, status)}
      end
    )
    |> IO.inspect(label: "UPDATE GOBBLER STATUS")
  end

  @spec deselect_gobbler(game :: game()) :: game()
  def deselect_gobbler(game) do
    case game.selected_gobbler.played? do
      nil -> deselect_unplayed_gobbler(game)
      {row, col} -> deselect_played_gobbler(game, {row, col})
    end
  end

  @spec deselect_played_gobbler(game :: game(), coords :: coords()) :: game()
  defp deselect_played_gobbler(game, coords) do
    game
    |> pop_first_gobbler(coords)
    |> update_gobbler_status(game.selected_gobbler.name, :not_selected)
    |> set_selected_gobbler(nil)
  end

  @spec deselect_unplayed_gobbler(game :: game()) :: game()
  defp deselect_unplayed_gobbler(game) do
    game
    |> update_gobbler_status(game.selected_gobbler.name, :not_selected)
    |> set_selected_gobbler(nil)
  end

  @spec set_gobbler_status(
          gobblers :: [gobbler()],
          gobbler_name :: gobbler_name(),
          status :: gobbler_status()
        ) :: [gobbler()]
  defp set_gobbler_status(gobblers, gobbler, status) do
    gobblers
    |> Enum.map(fn g ->
      if g.name == gobbler do
        %{name: g.name, status: status}
      else
        g
      end
    end)
  end

  @spec toggle_player_turn(game :: game()) :: game()
  def toggle_player_turn(game) do
    game
    |> Map.update!(:player_turn, &toggle_player/1)
  end

  @spec toggle_player(player()) :: player()
  defp toggle_player(:blue), do: :orange
  defp toggle_player(:orange), do: :blue
end
