defmodule Tictactwo.TableManager do
  use Agent

  def start_link(initial_val) do
    Agent.start_link(fn -> initial_val end, name: __MODULE__)
  end

  def create_table(num_games, current_user, :blue) do
    # TODO: Validate here
    tables = current_tables()

    if Enum.any?(tables, fn table ->
         table.owner == current_user.username or
           table.owner == current_user.username
       end) do
      {:error, "Player already has a table"}
    else
      new_table = %{
        num_games: num_games,
        owner: current_user.username,
        owner_id: current_user.id,
        owner_color: :blue
      }

      Agent.update(__MODULE__, &[new_table | &1])
      {:ok, Agent.get(__MODULE__, fn tables -> tables end)}
    end
  end

  def create_table(num_games, current_user, :orange) do
    # TODO: Validate here
    new_table = %{
      num_games: num_games,
      owner: current_user.username,
      owner_id: current_user.id,
      owner_color: :orange
    }

    {:ok, Agent.update(__MODULE__, &[new_table | &1])}
  end

  def cancel_table(owner) do
    Agent.update(__MODULE__, fn tables ->
      Enum.filter(tables, fn table -> table.owner != owner end)
    end)

    {:ok, Agent.get(__MODULE__, fn tables -> tables end)}
  end

  def current_tables() do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
