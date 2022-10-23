defmodule TictactwoWeb.Components.Player do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  alias TictactwoWeb.Components.Gobbler

  def info(assigns) do
    ~H"""
      <div>
        <div class="flex justify-between">
          <span>
            <%= show_player_name(@game, @color) %> 
          </span>
          <span>
            <%= @move_timer %>
          </span>
        </div>
        <Gobbler.list
          game={@game}
          current_user={@current_user}
          display_user={@display_user}
          color={@color}
          class="row-start-1 row-end-2"
        />
      </div>
    """
  end
end
