defmodule Tictactwo.TableManager do
  use Agent

  def start_link(initial_val) do
    Agent.start_link(fn -> initial_val end, name: __MODULE__)
  end

  def create_table(num_games, username, :blue) do
    # TODO: Validate here
    tables = current_tables()

    if Enum.any?(tables, fn table ->
         (table.blue_player != nil and table.blue_player.username == username) or
           (table.orange_player != nil and table.orange_player.username == username)
       end) do
      {:error, "Player already has a table"}
    else
      new_table = %{
        num_games: num_games,
        owner: username,
        blue_player: %{
          username: username
        },
        orange_player: nil
      }

      Agent.update(__MODULE__, &[new_table | &1])
      {:ok, Agent.get(__MODULE__, fn tables -> tables end)}
    end
  end

  def create_table(num_games, username, :orange) do
    # TODO: Validate here
    new_table = %{
      num_games: num_games,
      owner: username,
      blue_player: nil,
      orange_player: %{
        username: username
      }
    }

    {:ok, Agent.update(__MODULE__, &[new_table | &1])}
  end

  def current_tables() do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
