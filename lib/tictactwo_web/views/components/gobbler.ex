defmodule TictactwoWeb.Components.Gobbler do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  def list(assigns) do
    ~H"""
    <div class="flex flex-row w-screen max-w-screen-sm">
    <%= for gobbler <- not_selected_gobblers(@game, @user_type) do %>
      <.list_item
        game={@game}
        user_type={@user_type}
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
        disabled={
          not (@color == to_string(@user_type)) ||
          not my_turn?(@game, @user_type) || 
          not is_nil(@game.selected_gobbler)
        }
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
				disabled={not my_turn?(@game, @user_type)}
			  >
			    <%= @game.selected_gobbler.name %>
		  </button>
    """
  end

  def board_item(assigns) do 
    ~H"""
      <button
        class={"w-full h-full border-2 p-2 bg-#{get_current_user_color(@user_type)}-500"}
        disabled={
          not is_nil(@game.selected_gobbler) ||
          not my_turn?(@game, @user_type)
        }
        phx-click="select-gobbler"
        phx-value-gobbler={@gobbler.name} >
        <%= @gobbler.name %>
      </button>
    """
  end

end
