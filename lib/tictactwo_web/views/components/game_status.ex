defmodule TictactwoWeb.Components.GameStatus do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  def show_for_player(assigns) do
    ~H"""
      <div>
        <%= if @game.status == :in_play do %>
          <%= if my_turn?(@game, @user_type) do %>
            <p> It's your turn </p>
          <% else %>
            <p>Waiting for your opponent to play their move</p>
          <% end %>
        <% else %>
          <p><%= winning_player(@game)%> Won!!!</p>
        <% end %>
      </div>
    """
  end

  def show(assigns) do
    ~H"""
      <div>
        <%= if @game.status == :in_play do %>
          <h3><%= @game.player_turn %>'s turn</h3>
        <% else %>
          <h3>Game Ended</h3>
        <% end %>
      </div>
    """
  end
end
