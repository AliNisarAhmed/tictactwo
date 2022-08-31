defmodule TictactwoWeb.Components.Gobbler do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  def list(assigns) do
    ~H"""
    <%= for gobbler <- not_selected_gobblers(Map.get(@game, @current_player)) do %>
      <button
        class={"w-20 h-10 p-4 b-2 bg-#{@current_player |> to_string()}-500"}
        disabled={
          not is_nil(@game.selected_gobbler) ||
          not my_turn?(@current_user, @game) ||
          @game.player_turn != @current_player
        }
        phx-click="select-gobbler"
        phx-value-gobbler={gobbler.name} >
        <%= gobbler.name %>
      </button>
    <% end %>
    """
  end

end
