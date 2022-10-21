defmodule TictactwoWeb.Components.Board do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  alias Tictactwo.Games
  alias TictactwoWeb.Components.Gobbler

  def draw_board(assigns) do
    assigns = 
      assigns 
      |> assign(:selected_gobbler, assigns.game.selected_gobbler)

    ~H"""
    <div class={"#{@class} p-1 w-screen max-w-screen-sm"}>
    <div class="grid grid-cols-3 grid-rows-3 w-full">

    <%= for cell <- @game.cells do %>
      <div class="border-2 w-full h-28">

        <%= if is_nil(@selected_gobbler) do %>

          <%= if can_select_played_gobbler?(@game, @current_user, cell.gobblers) do %>

            <Gobbler.board_item 
              game={@game}
              cell={cell}
              on_click="select-gobbler"
              disabled={false}
            />

          <% else %> 

    				   <Gobbler.board_item 
                 game={@game}
                 cell={cell}
                 on_click={nil}
                 disabled={true}
                />

          <% end %>

        <% else %> 

           <Gobbler.board_item_selected 
             game={@game}
             current_user={@current_user}
             cell={cell}
           />

        <% end %>
      </div>
      <% end %>
    </div>
    </div>
    """
  end

  defp can_select_played_gobbler?(game, current_user, gobblers) do 
    my_turn?(game, current_user) && 
      can_select?(gobblers, current_user) && 
        game_not_ended?(game)
  end
end
