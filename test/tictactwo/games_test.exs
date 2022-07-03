defmodule Tictactwo.GamesTest do
  use Tictactwo.DataCase, async: true

  alias Tictactwo.Games

  describe "games: update_gobbler_status" do
    test "updates gobbler status to selected" do
      game = Games.new_game()
      result = Games.update_gobbler_status(game, :xl, :selected)
      updated_gobbler = Enum.find(result.blue.gobblers, fn g -> g.name == :xl end)

      assert updated_gobbler
      assert updated_gobbler.status == :selected
    end
  end

  describe "games: check winning condition" do
    test "empty game is in play" do
      game = %{
        cells: []
      }

      assert Games.game_status(game) == :in_play
    end

    test "test win on row" do
      game = %{
        cells: [
          %{coords: {0, 0}, gobblers: [{:blue, :xl}, {:orange, :large}]},
          %{coords: {0, 1}, gobblers: [{:blue, :large}, {:orange, :small}]},
          %{coords: {0, 2}, gobblers: [{:blue, :small}, {:orange, :xs}]}
        ]
      }

      assert Games.game_status(game) == {:won, :blue}
    end

    test "test win on col" do
      game = %{
        cells: [
          %{coords: {0, 0}, gobblers: [{:orange, :xl}, {:orange, :large}]},
          %{coords: {1, 0}, gobblers: [{:orange, :large}, {:blue, :small}]},
          %{coords: {2, 0}, gobblers: [{:orange, :small}, {:blue, :xs}]}
        ]
      }

      assert Games.game_status(game) == {:won, :orange}
    end

    test "test win on falling diag" do
      game = %{
        cells: [
          %{coords: {0, 0}, gobblers: [{:orange, :xl}, {:orange, :large}]},
          %{coords: {1, 1}, gobblers: [{:orange, :large}, {:blue, :small}]},
          %{coords: {2, 2}, gobblers: [{:orange, :small}, {:blue, :xs}]}
        ]
      }

      assert Games.game_status(game) == {:won, :orange}
    end

    test "test win on rising diag" do
      game = %{
        cells: [
          %{coords: {2, 0}, gobblers: [{:orange, :xl}, {:orange, :large}]},
          %{coords: {2, 2}, gobblers: [{:orange, :large}, {:blue, :small}]},
          %{coords: {0, 2}, gobblers: [{:orange, :small}, {:blue, :xs}]}
        ]
      }

      assert Games.game_status(game) == {:won, :orange}
    end

    test "test random moves" do
      game = %{
        cells: [
          %{coords: {3, 3}, gobblers: [{:orange, :xl}, {:orange, :large}]},
          %{coords: {2, 2}, gobblers: [{:blue, :large}, {:blue, :small}]},
          %{coords: {1, 3}, gobblers: [{:orange, :small}, {:blue, :xs}]},
          %{coords: {0, 1}, gobblers: [{:blue, :small}, {:blue, :xs}]}
        ]
      }

      assert Games.game_status(game) == :in_play
    end
  end
end
