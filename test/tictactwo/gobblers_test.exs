defmodule Tictactwo.GobblersTest do
  use Tictactwo.DataCase, async: true

  alias Tictactwo.Gobblers

  describe "compare" do
    test ":premie" do
      result = Gobblers.gobbler_names() |> Enum.map(fn n -> Gobblers.compare(:premie, n) end)
      assert [:lt, :lt, :lt, :lt, :lt, :eq] == result
    end

    test ":xs" do
      result = Gobblers.gobbler_names() |> Enum.map(fn n -> Gobblers.compare(:xs, n) end)
      assert [:lt, :lt, :lt, :lt, :eq, :gt] == result
    end

    test ":small" do
      result = Gobblers.gobbler_names() |> Enum.map(fn n -> Gobblers.compare(:small, n) end)
      assert [:lt, :lt, :lt, :eq, :gt, :gt] == result
    end

    test ":medium" do
      result = Gobblers.gobbler_names() |> Enum.map(fn n -> Gobblers.compare(:medium, n) end)
      assert [:lt, :lt, :eq, :gt, :gt, :gt] == result
    end

    test ":large" do
      result = Gobblers.gobbler_names() |> Enum.map(fn n -> Gobblers.compare(:large, n) end)
      assert [:lt, :eq, :gt, :gt, :gt, :gt] == result
    end

    test ":xl" do
      result = Gobblers.gobbler_names() |> Enum.map(fn n -> Gobblers.compare(:xl, n) end)
      assert [:eq, :gt, :gt, :gt, :gt, :gt] == result
    end
  end
end
