defmodule TictactwoWeb.Components.Gobbler do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  def list(assigns) do
    ~H"""
    <div class="flex flex-row">
    <%= for gobbler <- not_selected_gobblers(@game, @user_type) do %>
      <button
        class={"w-20 h-10 p-4 b-2 bg-#{get_current_user_color(@user_type)}-500"}
        disabled={
          not is_nil(@game.selected_gobbler) ||
          not my_turn?(@game, @user_type) ||
          @game.player_turn != @user_type
        }
        phx-click="select-gobbler"
        phx-value-gobbler={gobbler.name} >
        <%= gobbler.name %>
      </button>
    <% end %>
    </div>
    """
  end

end
