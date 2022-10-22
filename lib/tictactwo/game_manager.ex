defmodule Tictactwo.GameManager do
  use GenServer

  alias Tictactwo.{Games, Gobblers, CurrentGames}

  # 5 minutes
  @timeout 300_000

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
      rematch_offered_by: nil
    }

    with {:ok, _} <-
           DynamicSupervisor.start_child(
             Tictactwo.DynamicSupervisor,
             {__MODULE__, game}
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

  def update_game(new_game_state) do
    GenServer.call(via(new_game_state.slug), {:update_game, new_game_state})
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

  def handle_call({:update_game, new_game_state}, _from, _old_state) do
    {:reply, new_game_state, new_game_state, @timeout}
  end

  def handle_call({:game_ended, updated_game}, _from, _old_state) do
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

  # handle timeout
  def handle_info(:timeout, state) do
    DynamicSupervisor.terminate_child(Tictactwo.DynamicSupervisor, self())
    {:stop, :timed_out, state}
  end

  defp via(game_slug) do
    Tictactwo.GameRegistry.via(game_slug)
  end

  defp generate_slug(length \\ 12) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
