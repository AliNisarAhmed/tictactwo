defmodule Tictactwo.Gobblers do
  use Tictactwo.Types

  def gobbler_names() do
    [:xl, :large, :medium, :small, :xs, :premie]
  end

  @spec new_gobblers() :: [gobbler()]
  def new_gobblers() do
    gobbler_names()
    |> Enum.map(&%{name: &1, status: :not_selected})
  end

  @spec compare(gobbler_1 :: gobbler_name(), gobbler_2 :: gobbler_name()) :: :lt | :eq | :gt
  def compare(:premie, :premie), do: :eq
  def compare(:premie, _), do: :lt
  def compare(_, :premie), do: :gt

  def compare(:xs, :xs), do: :eq
  def compare(:xs, _), do: :lt

  def compare(:small, :small), do: :eq
  def compare(:small, :xs), do: :gt
  def compare(:small, _), do: :lt

  def compare(:medium, :xs), do: :gt
  def compare(:medium, :small), do: :gt
  def compare(:medium, :medium), do: :eq
  def compare(:medium, _), do: :lt

  def compare(:large, :xl), do: :lt
  def compare(:large, :large), do: :eq
  def compare(:large, _), do: :gt

  def compare(:xl, :xl), do: :eq
  def compare(:xl, _), do: :gt
end
