defmodule TictactwoWeb.Components.View do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  alias TictactwoWeb.Components.{Player, Board}

  def play(assigns) do
    ~H"""
      <%= if @user_type == :spectator do %>
        <.spectator 
          game={@game}
          user_type={@user_type}
        />
      <% else %> 
        <.player 
          game={@game}
          user_type={@user_type}
        />
      <% end %>
    """
  end

  def player(assigns) do
    ~H"""

    <Player.info
      game={@game}
      current_user={@user_type}
      display_user={toggle_user_type(@user_type)}
      color={get_current_user_color_type(toggle_user_type(@user_type))}
      class="row-start-1 row-end-2"
    />
    <Board.draw_board 
      game={@game} 
      current_user={@user_type}
      class="row-start-2 row-end-3"
    />
    <Player.info
      game={@game} 
      current_user={@user_type}
      display_user={@user_type}
      color={get_current_user_color_type(@user_type)}
      class="row-start-3 row-end-4"
    />
    """
  end

  def spectator(assigns) do
    ~H"""
    <Player.info
      game={@game}
      current_user={@user_type}
      display_user={:orange}
      color="orange"
      class="row-start-1 row-end-2"
    />
    <Board.draw_board 
      game={@game} 
      current_user={@user_type}
      class="row-start-2 row-end-3"
    />
    <Player.info
    game={@game} 
    current_user={@user_type}
    display_user={:blue}
    color="blue"
    class="row-start-3 row-end-4"
    />
    """
  end
end
