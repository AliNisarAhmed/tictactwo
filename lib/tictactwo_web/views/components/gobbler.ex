defmodule TictactwoWeb.Components.Gobbler do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  def list(assigns) do
    ~H"""
    <div class="flex flex-row w-screen max-w-screen-sm">
    <div>
      <.selected
        game={@game}
        current_user={@current_user}
        display_user={@display_user}
      />
    </div>
    <%= for gobbler <- not_selected_gobblers(@game, @display_user) do %>
      <.list_item
        game={@game}
        current_user={@current_user}
        display_user={@display_user}
        gobbler={gobbler}
        color={@color}
        class={@class}
      />
    <% end %>
    </div>
    """
  end

  def list_item(assigns) do
    ~H"""
      <button
        class={"#{@class} h-20 border-2 rounded-sm p-2 bg-#{@color}-500 grow basis-0 shrink min-w-0"}
        disabled={is_button_disabled?(@game, @current_user, @display_user)}
        phx-click="select-gobbler"
        phx-value-gobbler={@gobbler.name} >
        <%= @gobbler.name %>
      </button>
    """
  end

  def selected(assigns) do
    ~H"""
    <button 
      class={gobbler_class(@game.player_turn)}
      phx-click="deselect-gobbler"
      disabled={is_selected_disabled?(@game, @current_user, @display_user)}
     >
       <%= if not is_nil(@game.selected_gobbler) and my_turn?(@game, @display_user) do %>
         <%= @game.selected_gobbler.name %>
       <% end %>
    </button>
    """
  end

  def board_item(assigns) do
    ~H"""
      <button
        class={"w-full h-full border-2 p-2 bg-#{get_current_user_color_type(@current_user)}-500"}
        disabled={is_button_disabled?(@game, @current_user, @display_user)}
        phx-click="select-gobbler"
        phx-value-gobbler={@gobbler.name} >
        <%= @gobbler.name %>
      </button>
    """
  end

  defp is_button_disabled?(game, current_user, display_user) do
    not my_turn?(game, current_user) ||
      not is_nil(game.selected_gobbler) ||
      current_user != display_user || 
      game.status != :in_play
  end

  defp is_selected_disabled?(game, current_user, display_user) do
    not my_turn?(game, current_user) ||
      is_nil(game.selected_gobbler) ||
      current_user != display_user ||
      game.status != :in_play
  end
end
