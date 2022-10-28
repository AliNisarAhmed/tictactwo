defmodule Tictactwo.Games do
  use Tictactwo.Types

  alias Tictactwo.{Repo, Gobblers, GameManager}
  alias Tictactwo.Games.Game

  @spec new_game(player(), blue_username :: String.t(), orange_username :: String.t()) ::
          String.t()
  def new_game(player_turn, blue_username, orange_username) do
    with {:ok, game} <- GameManager.new_game(player_turn, blue_username, orange_username) do
      game.slug
    end
  end

  @spec select_already_played_gobbler(
          game :: game(),
          gobbler_name :: gobbler_name(),
          coords :: coords()
        ) :: game()
  def select_already_played_gobbler(game, gobbler_name, {row, col}) do
    selected_gobbler = %{
      name: gobbler_name,
      played?: {row, col}
    }

    updated_game =
      game
      |> pop_first_gobbler_from_cell({row, col})
      |> set_selected_gobbler(selected_gobbler)
      |> update_gobbler_status(gobbler_name, :selected)

    GameManager.update_game(updated_game)
  end

  @spec select_unplayed_gobbler(game :: game(), gobbler_name :: gobbler_name()) :: game()
  def select_unplayed_gobbler(game, gobbler_name) do
    selected_gobbler = %{
      name: gobbler_name,
      played?: nil
    }

    updated_game =
      game
      |> set_selected_gobbler(selected_gobbler)
      |> update_gobbler_status(gobbler_name, :selected)

    GameManager.update_game(updated_game)
  end

  @spec deselect_gobbler(game :: game()) :: game()
  def deselect_gobbler(game) do
    updated_game =
      case game.selected_gobbler.played? do
        nil -> deselect_unplayed_gobbler(game)
        {row, col} -> deselect_played_gobbler(game, {row, col})
      end

    GameManager.update_game(updated_game)
  end

  @spec play_gobbler(game :: game(), coords :: coords()) :: game()
  def play_gobbler(game, coords) do
    selected_gobbler = game.selected_gobbler
    gobbler_name = selected_gobbler.name

    updated_game =
      game
      |> push_gobbler_to_cell(coords)
      |> update_gobbler_status(gobbler_name, {:played, coords})
      |> set_selected_gobbler(nil)
      |> update_game_status()
      |> toggle_player_turn()

    cond do
      updated_game.status in [:blue_won, :orange_won] -> GameManager.end_game(updated_game)
      true -> GameManager.update_game(updated_game, reset_timers: true)
    end

    updated_game
  end

  @spec get_player_gobblers(game :: game(), player :: player()) :: [gobbler()]
  def get_player_gobblers(game, player) do
    Map.get(game, player)
  end

  def move_allowed?(game, gobblers) do
    gobblers
    |> List.first()
    |> then(fn
      {_, name} ->
        case Gobblers.compare(game.selected_gobbler.name, name) do
          :lt -> false
          :eq -> false
          _ -> true
        end

      _ ->
        true
    end)
  end

  def rematch_offered(game, username, color) do
    updated_game = Map.put(game, :rematch_offered_by, %{username: username, color: color})

    GameManager.update_game(updated_game)

    updated_game
  end

  def rematch_accepted(game) do
    player_turn = :blue

    {blue_username, orange_username} =
      case game.rematch_offered_by.color do
        "blue" -> {game.orange_username, game.rematch_offered_by.username}
        "orange" -> {game.rematch_offered_by.username, game.blue_username}
      end

    new_game(player_turn, blue_username, orange_username)
  end

  def fetch_players(slug) do
    GameManager.fetch_players(slug)
  end

  def get_game_by_slug!(slug) do
    GameManager.get_game_by_slug(slug)
  end

  @spec game_status(game :: game()) :: game_status()
  def game_status(game) do
    with :in_play <- check_rows(game.cells),
         :in_play <- check_cols(game.cells),
         :in_play <- check_falling_diag(game.cells) do
      check_rising_diag(game.cells)
    else
      v -> v
    end
  end

  @spec check_if_player_won?(game :: game(), player :: player()) :: boolean()
  def check_if_player_won?(%{status: :blue_won}, :blue), do: true
  def check_if_player_won?(%{status: :orange_won}, :orange), do: true
  def check_if_player_won?(_game, _player), do: false

  @spec gen_empty_cells() :: [cell()]
  def gen_empty_cells() do
    Enum.flat_map(0..2, fn row ->
      Enum.map(0..2, fn col ->
        gen_empty_cell(row, col)
      end)
    end)
  end

  @spec get_current_user_color(game :: game(), current_user :: current_user()) :: player()
  def get_current_user_color(game, current_user) do
    game
    |> Enum.find(fn {_key, val} -> val == current_user.username end)
    |> elem(0)
    |> case do
      :blue_username -> :blue
      :orange_username -> :orange
    end
  end

  @spec get_user_type(game(), current_user()) :: viewer_type()
  def get_user_type(game, current_user) do
    case current_user do
      %{username: username} when username == game.blue_username -> :blue
      %{username: username} when username == game.orange_username -> :orange
      _ -> :spectator
    end
  end

  @spec abort_game(game :: game(), username :: String.t()) :: game()
  def abort_game(game, username) do
    updated_game =
      game
      |> Map.put(:status, {:aborted, username})

    GameManager.end_game(updated_game)

    updated_game
  end

  @spec resign_game(game :: game(), username :: String.t()) :: game()
  def resign_game(game, username) do
    updated_game =
      game
      |> Map.put(:status, {:resigned, username})

    GameManager.end_game(updated_game)

    updated_game
  end

  # --------------------------------------------------------------
  # --------------------- DB FUNCTIONS ----------------------
  # --------------------------------------------------------------

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.update_changeset(attrs)
    |> Repo.update()
  end

  def save_game(game) do
    game
    # |> Ecto.Changeset.change(%{
    #   player_turn: game.player_turn,
    #   cells: game.cells,
    #   blue: game.blue,
    #   orange: game.orange
    # })
    |> Game.update_changeset(%{
      player_turn: game.player_turn,
      cells: game.cells,
      blue: game.blue,
      orange: game.orange
    })
    |> Repo.update!()
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  # --------------------------------------------------------------
  # --------------------- PRIVATE FUNCTIONS ----------------------
  # --------------------------------------------------------------

  @spec pop_first_gobbler_from_cell(game :: game(), coords :: coords()) :: game()
  defp pop_first_gobbler_from_cell(game, {row, col}) do
    Map.put(
      game,
      :cells,
      game.cells
      |> Enum.map(fn cell ->
        case cell.coords do
          {^row, ^col} -> Map.update!(cell, :gobblers, &Enum.drop(&1, 1))
          _ -> cell
        end
      end)
    )
  end

  @spec push_gobbler_to_cell(game :: game(), coords :: coords()) :: game()
  defp push_gobbler_to_cell(game, {row, col}) do
    Map.put(
      game,
      :cells,
      game.cells
      |> Enum.map(fn cell ->
        case cell.coords do
          {^row, ^col} ->
            Map.update!(cell, :gobblers, fn gs ->
              [{game.player_turn, game.selected_gobbler.name} | gs]
            end)

          _ ->
            cell
        end
      end)
    )
  end

  @spec set_selected_gobbler(game :: game(), selected_gobbler :: selected_gobbler()) :: game()
  defp set_selected_gobbler(game, selected_gobbler) do
    game
    |> Map.put(:selected_gobbler, selected_gobbler)
  end

  @spec update_gobbler_status(
          game :: game(),
          gobbler_name :: gobbler_name(),
          status :: gobbler_status()
        ) :: game()
  defp update_gobbler_status(game, gobbler_name, status) do
    game
    |> Map.update!(
      game.player_turn,
      fn gobblers -> set_gobbler_status(gobblers, gobbler_name, status) end
    )
  end

  @spec deselect_played_gobbler(game :: game(), coords :: coords()) :: game()
  defp deselect_played_gobbler(game, coords) do
    game
    |> push_gobbler_to_cell(coords)
    |> update_gobbler_status(game.selected_gobbler.name, {:played, coords})
    |> set_selected_gobbler(nil)
  end

  @spec deselect_unplayed_gobbler(game :: game()) :: game()
  defp deselect_unplayed_gobbler(game) do
    game
    |> update_gobbler_status(game.selected_gobbler.name, :not_selected)
    |> set_selected_gobbler(nil)
  end

  @spec set_gobbler_status(
          gobblers :: [gobbler()],
          gobbler_name :: gobbler_name(),
          status :: gobbler_status()
        ) :: [gobbler()]
  defp set_gobbler_status(gobblers, gobbler, status) do
    gobblers
    |> Enum.map(fn g ->
      if g.name == gobbler do
        %{name: g.name, status: status}
      else
        g
      end
    end)
  end

  @spec toggle_player_turn(game :: game()) :: game()
  defp toggle_player_turn(game) do
    case game.status do
      :in_play ->
        game
        |> Map.update!(:player_turn, &toggle_player/1)

      _ ->
        game
    end
  end

  # ------------------------------------------------------------------------

  @spec update_game_status(game :: game()) :: game()
  defp update_game_status(game) do
    Map.put(game, :status, game_status(game))
  end

  @spec check_rising_diag(cells :: cells()) :: game_status()
  defp check_rising_diag(cells) do
    diag =
      cells
      |> Enum.filter(fn
        %{coords: {2, 0}} -> true
        %{coords: {0, 2}} -> true
        %{coords: {2, 2}} -> true
        _ -> false
      end)

    check_win(diag)
  end

  @spec check_falling_diag(cells :: cells()) :: game_status()
  defp check_falling_diag(cells) do
    diag =
      cells
      |> Enum.filter(fn %{coords: {row, col}} -> row == col end)

    check_win(diag)
  end

  @spec check_rows(cells :: cells()) :: game_status()
  defp check_rows(cells) do
    first_row =
      cells
      |> Enum.filter(fn %{coords: {row, _col}} -> row == 0 end)

    second_row =
      cells
      |> Enum.filter(fn %{coords: {row, _col}} -> row == 1 end)

    third_row =
      cells
      |> Enum.filter(fn %{coords: {row, _col}} -> row == 2 end)

    with :in_play <- check_win(first_row),
         :in_play <- check_win(second_row) do
      check_win(third_row)
    else
      v -> v
    end
  end

  @spec check_cols(cells :: cells()) :: game_status()
  defp check_cols(cells) do
    first_col =
      cells
      |> Enum.filter(fn %{coords: {_row, col}} -> col == 0 end)

    second_col =
      cells
      |> Enum.filter(fn %{coords: {_row, col}} -> col == 1 end)

    third_col =
      cells
      |> Enum.filter(fn %{coords: {_row, col}} -> col == 2 end)

    with :in_play <- check_win(first_col),
         :in_play <- check_win(second_col) do
      check_win(third_col)
    else
      v -> v
    end
  end

  @spec check_win(cells :: cells) :: game_status()
  defp check_win(cells) do
    cells
    |> Enum.map(fn cell -> cell.gobblers |> List.first() end)
    |> then(fn
      [{p, _}, {p, _}, {p, _}] ->
        case p do
          :blue -> :blue_won
          :orange -> :orange_won
        end

      _ ->
        :in_play
    end)
  end

  @spec toggle_player(player()) :: player()
  defp toggle_player(:blue), do: :orange
  defp toggle_player(:orange), do: :blue

  @spec gen_empty_cell(row :: pos_integer(), col :: pos_integer()) :: cell()
  defp gen_empty_cell(row, col) do
    %{coords: {row, col}, gobblers: []}
  end

end
