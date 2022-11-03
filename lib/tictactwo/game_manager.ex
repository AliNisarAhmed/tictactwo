defmodule Tictactwo.GameManager do
  use GenServer

  use Tictactwo.Types

  alias Tictactwo.{Games, Gobblers, CurrentGames, TimeKeeper, GameSupervisor}

  # 5 minutes
  # @timeout 300_000
  @timeout 60_000
  @room_topic "rooms:"
  @time_per_move 10

  def child_spec(game_slug) do
    %{
      id: {__MODULE__, game_slug},
      start: {__MODULE__, :start_link, [game_slug]},
      restart: :transient
    }
  end

  def start_link(game) do
    GenServer.start_link(
      __MODULE__,
      game,
      name: via(game.slug)
    )
  end

  def init(game) do
    send(self(), :after_join)
    {:ok, game, @timeout}
  end

  def new_game(player_turn, blue_username, orange_username) do
    game_slug = generate_slug()

    new_gobblers = Gobblers.new_gobblers()

    game = %{
      slug: game_slug,
      status: :ready,
      player_turn: player_turn,
      blue_username: blue_username,
      orange_username: orange_username,
      cells: Games.gen_empty_cells(),
      blue: new_gobblers,
      orange: new_gobblers,
      selected_gobbler: nil,
      rematch_offered_by: nil,
      timers: default_timers()
    }

    with {:ok, _} <-
           DynamicSupervisor.start_child(
             Tictactwo.DynamicSupervisor,
             {GameSupervisor, game}
           ) do
      Tictactwo.CurrentGames.add_game(%{
        slug: game.slug,
        blue_username: game.blue_username,
        orange_username: game.orange_username
      })

      {:ok, game}
    else
      error -> {:error, "failed to start the game #{error}"}
    end
  end

  def get_game_by_slug(game_slug) do
    GenServer.call(via(game_slug), :get_game)
  end

  def update_game(new_game_state, opts \\ []) do
    GenServer.call(via(new_game_state.slug), {:update_game, new_game_state, opts})
  end

  def end_game(updated_game) do
    GenServer.call(via(updated_game.slug), {:game_ended, updated_game})
  end

  def fetch_players(game_slug) do
    GenServer.call(via(game_slug), :fetch_players)
  end

  # ---- --------- ----
  # ---- CALLBACKS ----
  # ---- --------- ----

  def handle_call(:get_game, _from, game) do
    {:reply, game, game, @timeout}
  end

  def handle_call({:update_game, new_game_state, opts}, _from, _old_state) do
    if Keyword.get(opts, :reset_timers) do
      new_game_state = %{new_game_state | timers: default_timers()}
      broadcast_time_reset(new_game_state)
      broadcast_game_update(new_game_state)
      {:reply, new_game_state, new_game_state, @timeout}
    else
      broadcast_game_update(new_game_state)
      {:reply, new_game_state, new_game_state, @timeout}
    end
  end

  def handle_call({:game_ended, updated_game}, _from, _old_state) do
    broadcast_game_update(updated_game)
    broadcast_time_stop(updated_game)
    CurrentGames.remove_game(updated_game.slug)
    {:reply, updated_game, updated_game, @timeout}
  end

  def handle_call(
        :fetch_players,
        _from,
        %{blue_username: blue_username, orange_username: orange_username} = game
      ) do
    {:reply, {blue_username, orange_username}, game, @timeout}
  end

  def handle_info(:after_join, game) do
    TictactwoWeb.Endpoint.subscribe(TimeKeeper.timer_updates_topic(game.slug))
    {:noreply, game}
  end

  # handle process message timeout
  def handle_info(:timeout, game) do
    DynamicSupervisor.terminate_child(Tictactwo.DynamicSupervisor, self())
    CurrentGames.remove_game(game.slug)
    {:stop, :timed_out, game}
  end

  # handle "tick" on each second
  def handle_info(%{event: "tick"}, game) do
    updated_timers = Map.update!(game.timers, game.player_turn, fn v -> v - 1 end)

    if Map.get(updated_timers, game.player_turn) == 0 do
      # player_turn lost the game, stop the timer and end the game
      updated_game =
        game
        |> Map.replace(:timers, updated_timers)
        |> Map.replace(:status, player_lost_on_time(game.player_turn))

      broadcast_game_update(updated_game)
      CurrentGames.remove_game(updated_game.slug)
      broadcast_time_stop(updated_game)
      {:noreply, updated_game}
    else
      updated_game = Map.replace(game, :timers, updated_timers)
      broadcast_game_update(updated_game)
      {:noreply, updated_game}
    end
  end

  # -------------------------------------------------------------

  defp via(game_slug) do
    Tictactwo.GameRegistry.via(game_slug)
  end

  defp generate_slug(length \\ 12) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  defp broadcast_game_update(game) do
    TictactwoWeb.Endpoint.broadcast(topic(game), "game-updated", game)
  end

  defp broadcast_time_reset(game) do
    TictactwoWeb.Endpoint.broadcast(TimeKeeper.timer_incoming_topic(game.slug), "reset-time", nil)
  end

  defp broadcast_time_stop(game) do
    TictactwoWeb.Endpoint.broadcast(TimeKeeper.timer_incoming_topic(game.slug), "stop-time", nil)
  end

  defp topic(game) do
    @room_topic <> "#{game.slug}"
  end

  defp default_timers() do
    %{blue: @time_per_move, orange: @time_per_move}
  end

  @spec player_lost_on_time(player :: player()) :: game_status()
  defp player_lost_on_time(:orange), do: :blue_won
  defp player_lost_on_time(:blue), do: :orange_won
end
