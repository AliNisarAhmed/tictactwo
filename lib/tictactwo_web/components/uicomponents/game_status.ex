defmodule TictactwoWeb.Components.GameStatus do
  use Phoenix.Component
  use Tictactwo.Types

  import TictactwoWeb.RoomView
  alias Tictactwo.Games

  attr :game, :map, required: true
  attr :user_type, :atom, required: true, values: [:blue, :orange, :spectator]

  def show_for_player(assigns) do
    ~H"""
      <div>
          <%= if game_not_ended?(@game) do %>
            <%= if my_turn?(@game, @user_type) do %>
              <p>Your turn</p>
            <% else %> 
              <p>Waiting for opponent</p>
            <% end %>
          <% else %>
            <p><%= game_ended_status_for_players(@game, @user_type) %></p>
          <% end %>
      </div>
    """
  end

  attr :game, :map, required: true

  def show_for_spectator(assigns) do
    ~H"""
      <div>
          <%= if game_in_play?(@game) do %>
            <p><%= @game.player_turn %>'s turn</p>
          <% else %>
            <p>Game Ended - <%= game_status_to_player(@game.status) %> won</p>
          <% end %>
      </div>
    """
  end

  @spec game_ended_status_for_players(game(), viewer_type()) :: String.t()
  defp game_ended_status_for_players(
         %{rematch_offered_by: %{username: username}},
         _current_user_type
       ) do
    "#{username} is offering a rematch"
  end

  defp game_ended_status_for_players(%{status: {:aborted, username}}, _current_user_type) do
    "Game aborted by #{username}"
  end

  defp game_ended_status_for_players(%{status: {:resigned, username}}, _current_user_type) do
    "#{username} resigned"
  end

  defp game_ended_status_for_players(game, current_user_type) do
    if Games.check_if_player_won?(game, current_user_type) do
      "You won"
    else
      "You lost"
    end
  end
end
