defmodule Tictactwo.GamesTest do
  use Tictactwo.DataCase, async: true

  use Tictactwo.Types

  alias Tictactwo.Games
  alias Tictactwo.Gobblers

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
        cells: [
          %{coords: {0, 0}, gobblers: []},
          %{coords: {0, 1}, gobblers: []},
          %{coords: {0, 2}, gobblers: []},
          %{coords: {1, 0}, gobblers: []},
          %{coords: {1, 1}, gobblers: []},
          %{coords: {1, 2}, gobblers: []},
          %{coords: {2, 0}, gobblers: []},
          %{coords: {2, 1}, gobblers: []},
          %{coords: {2, 2}, gobblers: []}
        ]
      }

      assert Games.game_status(game) == :in_play
    end

    test "test win on row" do
      game = %{
        cells: [
          %{coords: {0, 0}, gobblers: [{:blue, :xl}, {:orange, :large}]},
          %{coords: {0, 1}, gobblers: [{:blue, :large}, {:orange, :small}]},
          %{coords: {0, 2}, gobblers: [{:blue, :small}, {:orange, :xs}]},
          %{coords: {1, 0}, gobblers: [{:orange, :premie}]},
          %{coords: {1, 1}, gobblers: [{:orange, :medium}]},
          %{coords: {1, 2}, gobblers: []},
          %{coords: {2, 0}, gobblers: []},
          %{coords: {2, 1}, gobblers: []},
          %{coords: {2, 2}, gobblers: []}
        ]
      }

      assert Games.game_status(game) == {:won, :blue}
    end

    test "test win on col" do
      game = %{
        cells: [
          %{coords: {0, 0}, gobblers: [{:orange, :xl}, {:orange, :large}]},
          %{coords: {0, 1}, gobblers: []},
          %{coords: {0, 2}, gobblers: []},
          %{coords: {1, 0}, gobblers: [{:orange, :large}, {:blue, :small}]},
          %{coords: {1, 1}, gobblers: []},
          %{coords: {1, 2}, gobblers: []},
          %{coords: {2, 0}, gobblers: [{:orange, :small}, {:blue, :xs}]},
          %{coords: {2, 1}, gobblers: []},
          %{coords: {2, 2}, gobblers: []}
        ]
      }

      assert Games.game_status(game) == {:won, :orange}
    end

    test "test win on falling diag" do
      game = %{
        cells: [
          %{coords: {0, 0}, gobblers: [{:orange, :xl}, {:orange, :large}]},
          %{coords: {0, 1}, gobblers: []},
          %{coords: {0, 2}, gobblers: []},
          %{coords: {1, 0}, gobblers: []},
          %{coords: {1, 1}, gobblers: [{:orange, :large}, {:blue, :small}]},
          %{coords: {1, 2}, gobblers: []},
          %{coords: {2, 0}, gobblers: []},
          %{coords: {2, 2}, gobblers: [{:orange, :small}, {:blue, :xs}]},
          %{coords: {2, 1}, gobblers: []}
        ]
      }

      assert Games.game_status(game) == {:won, :orange}
    end

    test "test win on rising diag" do
      game = %{
        cells: [
          %{coords: {0, 0}, gobblers: []},
          %{coords: {0, 1}, gobblers: []},
          %{coords: {0, 2}, gobblers: [{:orange, :small}, {:blue, :xs}]},
          %{coords: {1, 0}, gobblers: []},
          %{coords: {1, 1}, gobblers: []},
          %{coords: {1, 2}, gobblers: []},
          %{coords: {2, 0}, gobblers: [{:orange, :xl}, {:orange, :large}]},
          %{coords: {2, 1}, gobblers: []},
          %{coords: {2, 2}, gobblers: [{:orange, :large}, {:blue, :small}]}
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

  describe "Games: play gobbler: " do
    @describetag :skip
    test "first gobbler played on new game" do
      player_turn = :blue
      coords = {0, 0}
      gobbler_name = :small

      game =
        Games.new_game()
        |> play_new(gobbler_name, coords)

      cell = Enum.find(game.cells, fn cell -> cell.coords == coords end)

      gobbler =
        Enum.find(game[player_turn].gobblers, fn %{name: name} ->
          name == gobbler_name
        end)

      assert is_nil(game.selected_gobbler)
      assert List.first(cell.gobblers) == {player_turn, gobbler_name}
      assert gobbler.status == {:played, coords}
    end

    test "one move by each player" do
      game =
        Games.new_game()
        |> play_new(:large, {0, 0})
        |> play_new(:small, {0, 1})

      blue_cell = find_cell(game, {0, 0})
      orange_cell = find_cell(game, {0, 1})

      blue_gobbler = find_gobbler(game, :blue, :large)
      orange_gobbler = find_gobbler(game, :orange, :small)

      assert is_nil(game.selected_gobbler)
      assert List.first(blue_cell.gobblers) == {:blue, :large}
      assert List.first(orange_cell.gobblers) == {:orange, :small}
    end

    test "blue plays already played gobbler again" do
      game =
        Games.new_game()
        |> play_new(:small, {0, 0})
        |> play_new(:large, {0, 1})
        |> play_already_played(:small, {0, 0}, {2, 0})

      cell_1 = find_cell(game, {0, 0})
      cell_2 = find_cell(game, {0, 1})
      cell_3 = find_cell(game, {2, 0})

      blue_gobbler = find_gobbler(game, :blue, :small)

      assert is_nil(game.selected_gobbler)
      assert Enum.empty?(cell_1.gobblers)
      assert List.first(cell_2.gobblers) == {:orange, :large}
      assert List.first(cell_3.gobblers) == {:blue, :small}
    end
  end

  describe "Games: move allowed: " do
    test "move allowed on an empty cell" do
      game = Games.new_game()

      cell = find_cell(game, {0, 0})

      assert Games.move_allowed?(game, cell.gobblers)
    end

    test "move allowed on a smaller gobbler" do
      game =
        Games.new_game()
        |> play_new(:premie, {0, 0})
        |> play_new(:xs, {0, 1})
        |> play_new(:small, {0, 2})
        |> play_new(:medium, {1, 0})
        |> play_new(:large, {1, 1})
        |> Games.set_selected_gobbler(%{name: :small, played?: nil})

      cell_1 = find_cell(game, {0, 0})
      cell_2 = find_cell(game, {0, 1})

      assert Games.move_allowed?(game, cell_1.gobblers)
      assert Games.move_allowed?(game, cell_2.gobblers)

      game = game |> Games.set_selected_gobbler(%{name: :medium, played?: nil})

      cell_1 = find_cell(game, {0, 1})
      cell_2 = find_cell(game, {0, 2})

      assert Games.move_allowed?(game, cell_1.gobblers)
      assert Games.move_allowed?(game, cell_2.gobblers)

      game = game |> Games.set_selected_gobbler(%{name: :large, played?: nil})

      cell_1 = find_cell(game, {0, 2})
      cell_2 = find_cell(game, {1, 0})

      assert Games.move_allowed?(game, cell_1.gobblers)
      assert Games.move_allowed?(game, cell_2.gobblers)
    end

    test "move NOT allowed on larger or equal gobbler" do
      game =
        Games.new_game()
        |> play_new(:xl, {0, 0})
        |> play_new(:large, {0, 1})
        |> play_new(:medium, {0, 2})
        |> play_new(:small, {1, 0})
        |> play_new(:xs, {1, 1})
        |> Games.set_selected_gobbler(%{name: :premie, played?: nil})

      cell_xl = find_cell(game, {0, 0})
      cell_large = find_cell(game, {0, 1})
      cell_medium = find_cell(game, {0, 2})
      cell_small = find_cell(game, {1, 0})
      cell_xs = find_cell(game, {1, 1})

      refute Games.move_allowed?(game, cell_xl.gobblers)
      refute Games.move_allowed?(game, cell_large.gobblers)
      refute Games.move_allowed?(game, cell_medium.gobblers)
      refute Games.move_allowed?(game, cell_small.gobblers)
      refute Games.move_allowed?(game, cell_xs.gobblers)

      game = game |> Games.set_selected_gobbler(%{name: :xs, played?: nil})

      cell_xl = find_cell(game, {0, 0})
      cell_large = find_cell(game, {0, 1})
      cell_medium = find_cell(game, {0, 2})
      cell_small = find_cell(game, {1, 0})
      cell_xs = find_cell(game, {1, 1})

      refute Games.move_allowed?(game, cell_xl.gobblers)
      refute Games.move_allowed?(game, cell_large.gobblers)
      refute Games.move_allowed?(game, cell_medium.gobblers)
      refute Games.move_allowed?(game, cell_small.gobblers)
      refute Games.move_allowed?(game, cell_xs.gobblers)

      game = game |> Games.set_selected_gobbler(%{name: :small, played?: nil})

      cell_xl = find_cell(game, {0, 0})
      cell_large = find_cell(game, {0, 1})
      cell_medium = find_cell(game, {0, 2})
      cell_small = find_cell(game, {1, 0})

      refute Games.move_allowed?(game, cell_xl.gobblers)
      refute Games.move_allowed?(game, cell_large.gobblers)
      refute Games.move_allowed?(game, cell_medium.gobblers)
      refute Games.move_allowed?(game, cell_small.gobblers)

      game = game |> Games.set_selected_gobbler(%{name: :medium, played?: nil})

      cell_xl = find_cell(game, {0, 0})
      cell_large = find_cell(game, {0, 1})
      cell_medium = find_cell(game, {0, 2})

      refute Games.move_allowed?(game, cell_xl.gobblers)
      refute Games.move_allowed?(game, cell_large.gobblers)
      refute Games.move_allowed?(game, cell_medium.gobblers)

      game = game |> Games.set_selected_gobbler(%{name: :large, played?: nil})

      cell_xl = find_cell(game, {0, 0})
      cell_large = find_cell(game, {0, 1})

      refute Games.move_allowed?(game, cell_xl.gobblers)
      refute Games.move_allowed?(game, cell_large.gobblers)
    end
  end

  # ------------------ TEST HELPERS ----------------------------

  @spec play_new(game :: game(), gobbler_name :: gobbler_name(), coords :: coords()) :: game()
  defp play_new(game, gobbler_name, coords) do
    game
    |> Games.set_selected_gobbler(%{name: gobbler_name})
    |> Games.play_gobbler(coords)
  end

  @spec play_already_played(game(), gobbler_name(), coords(), coords()) :: game()
  defp play_already_played(game, gobbler_name, gobbler_coords, coords) do
    game
    |> Games.set_selected_gobbler(%{name: gobbler_name, played?: gobbler_coords})
    |> Games.play_gobbler(coords)
  end

  @spec find_cell(game :: game(), coords :: coords()) :: cell() | nil
  defp find_cell(game, coords) do
    game.cells
    |> Enum.find(fn cell -> cell.coords == coords end)
  end

  defp find_gobbler(game, player_name, gobbler_name) do
    game[player_name].gobblers
    |> Enum.find(fn %{name: name} -> name == gobbler_name end)
  end

  describe "games" do
    alias Tictactwo.Games.Game

    import Tictactwo.GamesFixtures

    @invalid_attrs %{blue: nil, orange: nil, player_turn: nil, slug: nil, status: nil}

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Games.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Games.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{blue: "some blue", orange: "some orange", player_turn: "some player_turn", slug: "some slug", status: "some status"}

      assert {:ok, %Game{} = game} = Games.create_game(valid_attrs)
      assert game.blue == "some blue"
      assert game.orange == "some orange"
      assert game.player_turn == "some player_turn"
      assert game.slug == "some slug"
      assert game.status == "some status"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      update_attrs = %{blue: "some updated blue", orange: "some updated orange", player_turn: "some updated player_turn", slug: "some updated slug", status: "some updated status"}

      assert {:ok, %Game{} = game} = Games.update_game(game, update_attrs)
      assert game.blue == "some updated blue"
      assert game.orange == "some updated orange"
      assert game.player_turn == "some updated player_turn"
      assert game.slug == "some updated slug"
      assert game.status == "some updated status"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_game(game, @invalid_attrs)
      assert game == Games.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Games.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Games.change_game(game)
    end
  end
end
