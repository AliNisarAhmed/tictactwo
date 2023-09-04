defmodule TictactwoWeb.Components.View do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  alias TictactwoWeb.Components.{Player, Board}
  alias PetalComponents.HeroiconsV1

  attr :user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :game, :any, required: true
  attr :move_timers, :map, required: true
  attr :online_status, :map, required: true

  def play(assigns) do
    ~H"""
    <%= if @user_type == :spectator do %>
      <.spectator
        game={@game}
        user_type={@user_type}
        move_timers={@move_timers}
        online_status={@online_status}
      />
    <% else %>
      <.player
        game={@game}
        user_type={@user_type}
        move_timers={@move_timers}
        online_status={@online_status}
      />
    <% end %>
    """
  end

  attr :game, :map, required: true
  attr :user_type, :atom, required: true, values: [:blue, :orange]
  attr :move_timers, :map, required: true

  def player(assigns) do
    assigns =
      assigns
      |> assign(:opponent_type, toggle_user_type(assigns.user_type))

    ~H"""
    <Player.info
      game={@game}
      current_user_type={@user_type}
      displayed_user_type={@opponent_type}
      color={get_current_user_color_type(@opponent_type)}
      move_timer={@move_timers[@opponent_type]}
      user_online?={get_user_status(@online_status, @opponent_type)}
      class="row-start-1 row-end-2"
      bottom={false}
    />
    <Board.draw_board game={@game} current_user_type={@user_type} class="row-start-2 row-end-3" />
    <Player.info
      game={@game}
      current_user_type={@user_type}
      displayed_user_type={@user_type}
      color={get_current_user_color_type(@user_type)}
      move_timer={@move_timers[@user_type]}
      user_online?={get_user_status(@online_status, @user_type)}
      class="row-start-3 row-end-4"
      bottom={true}
    />
    """
  end

  attr :game, :map, required: true
  attr :user_type, :atom, required: true, values: [:spectator]
  attr :move_timers, :map, required: true

  def spectator(assigns) do
    ~H"""
    <Player.info
      game={@game}
      current_user_type={@user_type}
      displayed_user_type={:orange}
      color={get_current_user_color_type(:orange)}
      move_timer={@move_timers.orange}
      user_online?={get_user_status(@online_status, :orange)}
      class="row-start-1 row-end-2"
    />
    <Board.draw_board game={@game} current_user_type={@user_type} class="row-start-2 row-end-3" />
    <Player.info
      game={@game}
      current_user_type={@user_type}
      displayed_user_type={:blue}
      color={get_current_user_color_type(:blue)}
      move_timer={@move_timers.blue}
      user_online?={get_user_status(@online_status, :blue)}
      class="row-start-3 row-end-4"
    />
    """
  end

  def spectator_count(assigns) do
    ~H"""
    <div :if={@count > 0} class="flex">
      <HeroiconsV1.Outline.user class="w-6 h-6" />
      <span><%= @count %></span>
    </div>
    """
  end
end
