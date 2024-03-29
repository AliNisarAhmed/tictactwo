defmodule Tictactwo.GameSupervisor do
  alias Tictactwo.{TimeKeeper, GameManager, GameRegistry}

  use Supervisor

  def start_link(game) do
    Supervisor.start_link(__MODULE__, game, name: GameRegistry.via("GameSupervisor_#{game.slug}"))
  end

  @impl true
  def init(game) do
    children = [
      {GameManager, game},
      {TimeKeeper, game}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
