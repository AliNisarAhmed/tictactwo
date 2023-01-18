defmodule TictactwoWeb.Components.View do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  alias TictactwoWeb.Components.{Player, Board}
  alias PetalComponents.HeroiconsV1

  attr :user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :game, :any, required: true
  attr :move_timers, :map, required: true

  def play(assigns) do
    ~H"""
      <%= if @user_type == :spectator do %>
        <.spectator 
          game={@game}
          user_type={@user_type}
          move_timers={@move_timers}
        />
      <% else %> 
        <.player 
          game={@game}
          user_type={@user_type}
          move_timers={@move_timers}
        />
      <% end %>
    """
  end

  attr :game, :map, required: true
  attr :user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :move_timers, :map, required: true

  def player(assigns) do
    assigns =
      assigns
      |> assign(:opponent_type, toggle_user_type(assigns.user_type))

    ~H"""

    <Player.info
      game={@game}
      current_user={@user_type}
      display_user={@opponent_type}
      color={get_current_user_color_type(@opponent_type)}
      move_timer={@move_timers[@opponent_type]}
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
      move_timer={@move_timers[@user_type]}
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
      move_timer={@move_timers.orange}
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
    move_timer={@move_timers.blue}
    color="blue"
    class="row-start-3 row-end-4"
    />
    """
  end

  def spectator_count(assigns) do
    ~H"""
    <div class="flex" :if={@count > 0}>
      <HeroiconsV1.Outline.user class="w-6 h-6"/>
      <span><%= @count %></span>
    </div>
    """
  end
end
