defmodule Tictactwo.GameSupervisor do
  alias Tictactwo.{TimeKeeper, GameManager}

  use Supervisor

  def start_link(game) do
    Supervisor.start_link(__MODULE__, game, name: String.to_atom("GameSupervisor_#{game.slug}"))
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
