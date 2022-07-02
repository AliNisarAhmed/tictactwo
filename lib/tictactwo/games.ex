defmodule Tictactwo.Games do
  def new_game(player_turn \\ :blue) do
    %{
      blue: %{
        username: "fletcher2033",
        gobblers: new_gobblers()
      },
      orange: %{
        username: "marlee1921",
        gobblers: new_gobblers()
      },
      cells: gen_empty_cells(),
      player_turn: player_turn,
      selected_gobbler: nil
    }
  end

  defp new_gobblers() do
    [:xl, :large, :medium, :small, :xs, :premie]
    |> Enum.map(&%{name: &1, status: :not_selected})
  end

  defp gen_empty_cell(row, col) do
    %{coords: {row, col}, gobblers: []}
  end

  defp gen_empty_cells() do
    Enum.flat_map(0..2, fn row ->
      Enum.map(0..2, fn col ->
        gen_empty_cell(row, col)
      end)
    end)
  end
end
