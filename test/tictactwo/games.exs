defmodule Tictactwo.GamesTest do
  use Tictactwo.DataCase, async: true

  alias Tictactwo.Games

  describe "games: " do
    test "updates gobbler status to selected" do
      game = Games.new_game()
      result = Games.update_gobbler_status(game, :xl, :selected)
      updated_gobbler = Enum.find(result.blue.gobblers, fn g -> g.name == :xl end)

      assert updated_gobbler
      assert updated_gobbler.status == :selected
    end
  end
end
