defmodule TictactwoWeb.Components.GameStatus do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  alias Tictactwo.Games

  def show_for_player(assigns) do
    ~H"""
      <div>
          <%= if game_in_play?(@game) do %>
            <%= if my_turn?(@game, @current_user) do %>
              <p>Your turn</p>
            <% else %> 
              <p>Waiting for opponent</p>
            <% end %>
          <% else %>
            <p><%= game_ended_status(@game, @current_user) %></p>
          <% end %>
      </div>
    """
  end

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

  defp game_ended_status(%{rematch_offered_by: %{ username: username }}, _current_user) do
    "#{username} is offering a rematch"
  end

  defp game_ended_status(%{status: {:aborted, _}}, _current_user) do 
    "Game aborted"
  end
  defp game_ended_status(game, current_user) do
    if Games.check_if_player_won?(game, current_user) do
      "You won"
    else
      "You lost"
    end
  end
end
