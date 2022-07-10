defmodule Tictactwo.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tictactwo.Games` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        blue: "some blue",
        orange: "some orange",
        player_turn: "some player_turn",
        slug: "some slug",
        status: "some status"
      })
      |> Tictactwo.Games.create_game()

    game
  end
end
