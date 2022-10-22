defmodule Tictactwo.CurrentGames do
  use GenServer

  @current_games_count 5
  @current_games_topic "current_games"

  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def init(state) do
    {:ok, state}
  end

  def topic() do
    @current_games_topic
  end

  def add_game(game_info) do
    GenServer.cast(__MODULE__, {:add_game, game_info})
  end

  # ---------------------------

  def handle_cast({:add_game, game_info}, current_games) do
    new_state =
      [game_info | current_games]
      |> Enum.take(@current_games_count)

    TictactwoWeb.Endpoint.broadcast(@current_games_topic, "game-added", new_state)

    {:noreply, new_state}
  end
end
