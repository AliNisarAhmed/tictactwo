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

  def remove_game(game_slug) do
    GenServer.cast(__MODULE__, {:remove_game, game_slug})
  end

  def get_current_games() do
    GenServer.call(__MODULE__, :get_current_games)
  end

  # ---------------------------

  def handle_call(:get_current_games, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:add_game, game_info}, current_games) do
    new_state =
      [game_info | current_games]
      |> Enum.take(@current_games_count)

    broadcast_event(new_state)

    {:noreply, new_state}
  end

  def handle_cast({:remove_game, game_slug}, current_games) do
    new_state = Enum.filter(current_games, fn game -> game.slug != game_slug end)
    broadcast_event(new_state)
    {:noreply, new_state}
  end

  # ----------------------------

  defp broadcast_event(new_state) do
    TictactwoWeb.Endpoint.broadcast(@current_games_topic, "current-games-updated", new_state)
  end
end
