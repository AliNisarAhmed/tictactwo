defmodule TictactwoWeb.Components.Gobbler do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  alias Tictactwo.Games

  def list(assigns) do
    ~H"""
    <div class="flex flex-row w-screen max-w-screen-sm">
    <div>
      <.selected
        game={@game}
        current_user={@current_user}
        display_user={@display_user}
        color={@color}
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
        disabled={is_button_disabled?(@game, @current_user, @display_user)}
        phx-click="select-gobbler"
        phx-value-gobbler={@gobbler.name} >
          <.gobbler_image name={@gobbler.name} color={@color} />
      </button>
    """
  end

  def selected(assigns) do
    ~H"""
    <button 
      phx-click="deselect-gobbler"
      disabled={is_selected_disabled?(@game, @current_user, @display_user)}
     >
       <%= if not is_nil(@game.selected_gobbler) and my_turn?(@game, @display_user) do %>
        <.gobbler_image name={@game.selected_gobbler.name} color={@color} />
       <% end %>
    </button>
    """
  end

  def board_item(assigns) do 
    assigns = 
      assigns 
      |> assign(:first_gobbler, first_gobbler(assigns.cell.gobblers))
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <%= if @first_gobbler do %>
      <button 
          phx-click={@on_click}
    		  phx-value-gobbler={@first_gobbler.name}
    		  phx-value-row={elem(assigns.cell.coords, 0)}
    		  phx-value-col={elem(assigns.cell.coords, 1)}
    		  disabled={@disabled}
    		  class={"w-full h-full #{@class}"}
    	  >
          <.gobbler_image 
            name={@first_gobbler.name} 
            color={get_current_user_color_type(@first_gobbler.color)} />
      </button>
    <% end %>
    """
  end

  def board_item_selected(assigns) do 
    assigns = 
      assigns 
      |> assign(:my_turn, my_turn?(assigns.game, assigns.current_user))
      |> assign(:move_allowed, Games.move_allowed?(assigns.game, assigns.cell.gobblers))
      |> assign(:played_gobbler_color, played_gobbler_color(assigns.cell.gobblers))
      |> assign(:row_value, elem(assigns.cell.coords, 0))
      |> assign(:col_value, elem(assigns.cell.coords, 1))
      |> assign(:first_gobbler, first_gobbler(assigns.cell.gobblers))

    ~H"""
      <button
        phx-click="play-gobbler"
        disabled={not @my_turn or not @move_allowed}
        class={"
          #{if @my_turn and @move_allowed, do: "cursor-pointer", else: "cursor-not-allowed"}
          #{hide_last_gobbler(@game, @cell.coords)}
        "}
      >
        <%= if not is_nil(@first_gobbler) and not first_gobbler_selected?(@first_gobbler, @game.selected_gobbler, @game.player_turn) do %>
          <.gobbler_image 
            name={@first_gobbler.name}
            color={@first_gobbler.color}
          />
        <% end %>
      </button>
    """
  end

  def gobbler_image(assigns) do 
    assigns = 
      assigns 
      |> assign(:gobbler_file, "#{assigns.name}-#{assigns.color}")

    ~H"""
    <%= PhoenixInlineSvg.Helpers.svg_image(TictactwoWeb.Endpoint, @gobbler_file, class: "w-full h-full") %>
    """
  end

  defp is_button_disabled?(game, current_user, display_user) do
    not my_turn?(game, current_user) ||
      not is_nil(game.selected_gobbler) ||
      current_user != display_user || 
       game_ended?(game)
  end

  defp is_selected_disabled?(game, current_user, display_user) do
    not my_turn?(game, current_user) ||
      is_nil(game.selected_gobbler) ||
      current_user != display_user ||
        game_ended?(game)
  end

end
