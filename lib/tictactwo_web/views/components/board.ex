defmodule TictactwoWeb.Components.Board do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  alias Tictactwo.Games

  def draw_board(assigns) do
    ~H"""
    <div class="grid grid-cols-3 grid-rows-3 w-1/2 max-w-xs">
    <%= for cell <- @game.cells do %>
    <div class="border-2 w-full h-full">
    <%= if is_nil(@game.selected_gobbler) do %>
    	<%= if my_turn?(@game, @user_type) and
    			can_select?(cell.gobblers, @game.player_turn) do %>
    		<button phx-click="select-gobbler"
    				phx-value-gobbler={first_gobbler_name(cell.gobblers)}
    				phx-value-row={elem(cell.coords, 0)}
    				phx-value-col={elem(cell.coords, 1)}
    				class="w-full h-full"
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
    	<button phx-click="play-gobbler"
    			phx-value-row={elem(cell.coords, 0)}
    			phx-value-col={elem(cell.coords, 1)}
    			class={"
    				w-full
    				h-full
    				#{set_cursor(@game, cell.gobblers)}
    				#{hide_last_gobbler(@game, cell.coords)}
    			"}
    			disabled={not Games.move_allowed?(@game, cell.gobblers)}
    	>
    			<span class={"#{played_gobbler_color(cell.gobblers)}"}>
    				<%= played_gobbler_text(cell.gobblers) %>
    			</span>
    	</button>
    <% end %>
    </div>
    <% end %>
    </div>
    """
  end
end
