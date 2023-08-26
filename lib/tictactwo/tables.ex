defmodule Tictactwo.Tables do
  alias Tictactwo.TableManager

  @tables_topic "tables_topic"

  def create_table(num_games, current_user, color) do
    with {:ok, tables} <- TableManager.create_table(num_games, current_user, color) do
      broadcast_event(tables)
    else
      error -> {:error, error}
    end
  end

  def cancel_table(owner) do
    with {:ok, tables} <- TableManager.cancel_table(owner) do
      broadcast_event(tables)
    end
  end

  defp broadcast_event(new_state) do
    TictactwoWeb.Endpoint.broadcast(@tables_topic, "tables_updated", new_state)
  end

  def get_current_tables() do
    TableManager.current_tables()
  end
end
