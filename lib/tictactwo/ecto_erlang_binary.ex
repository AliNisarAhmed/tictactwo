defmodule Tictactwo.EctoErlangBinary do
  use Ecto.Type

  def type, do: :binary

  def cast(:any, term), do: {:ok, term}
  def cast(term), do: {:ok, term}

  def load(raw_binary) when is_binary(raw_binary) do
    {:ok, :erlang.binary_to_term(raw_binary)}
  end

  def dump(term), do: {:ok, :erlang.term_to_binary(term)}
end
