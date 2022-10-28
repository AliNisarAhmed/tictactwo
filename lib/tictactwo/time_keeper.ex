defmodule Tictactwo.TimeKeeper do
  use GenServer

  alias Tictactwo.GameRegistry

  @time_per_move 25

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
      name: GameRegistry.via("timekeeper-#{game.slug}")
    )
  end

  def init(game) do
    send(self(), :after_join)

    {:ok,
     %{
       game_slug: game.slug,
       current_time: @time_per_move,
       timerRef: nil
     }}
  end

  def handle_info(:after_join, state) do
    TictactwoWeb.Endpoint.subscribe(timer_incoming_topic(state.game_slug))
    {:ok, timerRef} = :timer.send_interval(1000, self(), :tick)
    {:noreply, Map.replace(state, :timerRef, timerRef)}
  end

  def handle_info(:tick, state) do
    new_state =
      state
      |> Map.update(:current_time, 0, fn prev -> prev - 1 end)

    if new_state.current_time <= 0 do
      :timer.cancel(state.timerRef)
      publish_time_event("time-ran-out", %{current_time: 0}, state.game_slug)
    else
      publish_time_event("tick", %{current_time: new_state.current_time}, state.game_slug)
    end

    {:noreply, new_state}
  end

  def handle_info(%{event: "reset-time"}, state) do
    :timer.cancel(state.timerRef)
    {:ok, new_timer_ref} = :timer.send_interval(1000, self(), :tick)

    new_state =
      state
      |> Map.replace(:current_time, @time_per_move)
      |> Map.replace(:timerRef, new_timer_ref)

    {:noreply, new_state}
  end

  def handle_info(%{event: "stop-time"}, state) do
    if state.timerRef do
      :timer.cancel(state.timerRef)
    end

    state = Map.replace(state, :timerRef, nil)
    {:noreply, state}
  end

  def timer_updates_topic(game_slug) do
    "timer-#{game_slug}-updates"
  end

  def timer_incoming_topic(game_slug) do
    "timer-#{game_slug}-incoming"
  end

  defp publish_time_event(event, msg, game_slug) do
    TictactwoWeb.Endpoint.broadcast(
      timer_updates_topic(game_slug),
      event,
      msg
    )
  end
end
