defmodule TictactwoWeb.Components.Board do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  alias Tictactwo.Games

  def draw_board(assigns) do
    ~H"""
    <div class={"#{@class} p-1 w-screen max-w-screen-sm"}>
    <div class="grid grid-cols-3 grid-rows-3 w-full">
    <%= for cell <- @game.cells do %>
      <div class="border-2 w-full h-28">
        <%= if is_nil(@game.selected_gobbler) do %>
    	    <%= if can_select_played_gobbler?(@game, @current_user, cell.gobblers) do %>
    		    <button phx-click="select-gobbler"
    				    phx-value-gobbler={first_gobbler_name(cell.gobblers)}
    				    phx-value-row={elem(cell.coords, 0)}
    				    phx-value-col={elem(cell.coords, 1)}
    		      >
    			      <span class={"#{played_gobbler_color(cell.gobblers)}"}>
    				      <%= played_gobbler_text(cell.gobblers) %>
    			      </span>
    		    </button>
    	    <% else %>
    		    <%= if first_gobbler_selected?(
    					    cell.gobblers,
    					    @game.selected_gobbler,
    					    @game.player_turn
    			    ) do %>
    			    <button class="w-full h-full"
    					    disabled
    			    ></button>
    		    <% else %>
    			    <button class="w-full h-full"
    					    disabled
    			    >
    				    <span class={"#{played_gobbler_color(cell.gobblers)}"}>
    					    <%= played_gobbler_text(cell.gobblers) %>
    				    </span>
    			    </button>
    		    <% end %>
    	    <% end %>
        <% else %>
    	    <.gobbler_selected
            my_turn={my_turn?(@game, @current_user)}
            move_allowed={Games.move_allowed?(@game, cell.gobblers)}
            played_gobbler_text={played_gobbler_text(cell.gobblers)}
            played_gobbler_color={played_gobbler_color(cell.gobblers)}
            hide_last_gobbler={hide_last_gobbler(@game, cell.coords)}
            row_value={elem(cell.coords, 0)}
            col_value={elem(cell.coords, 1)}
    	    />
          <% end %>
        </div>
      <% end %>
      </div>
    </div>
    """
  end

  def gobbler_selected(assigns) do 
    ~H"""
      <button
        phx-click="play-gobbler"
        phx-value-row={@row_value}
        phx-value-col={@col_value}
        disabled={not @my_turn or not @move_allowed}
        class={"
          w-full
          h-full
          #{if @my_turn and @move_allowed, do: "cursor-pointer", else: "cursor-not-allowed"}
          #{@hide_last_gobbler}
        "}
      >
    		<span class={"#{@played_gobbler_color}"}>
    			<%= @played_gobbler_text %>
    		</span>
      </button>
    """
  end

  defp can_select_played_gobbler?(game, current_user, gobblers) do 
    my_turn?(game, current_user) && 
      can_select?(gobblers, current_user) && 
        game_in_play?(game)
  end
end
