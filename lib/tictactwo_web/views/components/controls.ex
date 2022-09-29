defmodule TictactwoWeb.Components.Controls do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  def panel(assigns) do
    ~H"""
      <div class="flex">
        <%= if rematch_offered?(@game, @current_user, @user_type) do %>
          <button 
            phx-click="rematch-accepted"
            phx-value-acceptor={@current_user.username}
          >
            Accept Rematch
          </button>
        <% else %>
          <%= if not game_in_play?(@game) do %>
            <button 
              phx-click="offer-rematch"
              phx-value-username={@current_user.username}
            >
              Rematch
            </button>
          <% end %>
        <% end %>
      </div>
    """
  end
end
