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
            <%= if Games.check_if_player_won?(@game, @current_user) do %> 
              <p>You won</p>
            <% else %>
              <p>You lost</p>
            <% end %>
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
            <p>Game Ended - <%= @game.status.player %> won</p>
          <% end %>
      </div>
    """
  end

end
