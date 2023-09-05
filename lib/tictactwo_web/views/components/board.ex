defmodule TictactwoWeb.Components.Board do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  alias TictactwoWeb.Components.Gobbler

  attr :class, :string, required: false, default: ""
  attr :game, :any, required: true
  attr :current_user_type, :atom, required: true, values: [:blue, :orange, :spectator]

  def draw_board(assigns) do
    assigns =
      assigns
      |> assign(:selected_gobbler, assigns.game.selected_gobbler)

    ~H"""
    <div class={"#{@class} p-1 w-screen max-w-screen-sm"}>
      <div class={"grid grid-cols-3 grid-rows-3 w-full bg-gradient-to-br from-#{@game.player_turn}-100 to-white-200"}>
        <%= for cell <- @game.cells do %>
          <div class={"w-full h-28
             #{if elem(cell.coords, 1) != 2, do: "border-r-8 border-r-blue-400"}
             #{if elem(cell.coords, 0) != 2, do: "border-b-8 border-b-orange-500"}
             "}>
            <%= if is_nil(@selected_gobbler) do %>
              <%= if can_select_played_gobbler?(@game, @current_user_type, cell.gobblers) do %>
                <Gobbler.board_item
                  game={@game}
                  cell={cell}
                  on_click="select-gobbler"
                  disabled={false}
                />
              <% else %>
                <Gobbler.board_item game={@game} cell={cell} disabled={true} />
              <% end %>
            <% else %>
                <Gobbler.board_item_selected
                  game={@game}
                  current_user_type={@current_user_type}
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
