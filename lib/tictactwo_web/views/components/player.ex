defmodule TictactwoWeb.Components.Player do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  import PetalComponents.Badge

  alias TictactwoWeb.Components.Gobbler
  alias TictactwoWeb.Components.UserStatus

  attr :game, :map, required: true
  attr :color, :string, required: true, values: ["primary", "secondary"]
  attr :move_timer, :map, required: true
  attr :current_user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :displayed_user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :user_online?, :boolean, required: true
  attr :class, :string, default: ""
  attr :bottom, :boolean, default: false

  def info(%{bottom: true} = assigns) do
    assigns =
      assigns
      |> assign(:hours, format_time(assigns.move_timer, &div/2))
      |> assign(:minutes, format_time(assigns.move_timer, &rem/2))

    ~H"""
    <div class="">
      <Gobbler.list
        game={@game}
        current_user_type={@current_user_type}
        displayed_user_type={@displayed_user_type}
        color={@color}
        class={@class}
      />
      <.player_info
        user_online?={@user_online?}
        game={@game}
        displayed_user_type={@displayed_user_type}
        hours={@hours}
        minutes={@minutes}
      >
      </.player_info>
    </div>
    """
  end

  def info(assigns) do
    assigns =
      assigns
      |> assign(:hours, format_time(assigns.move_timer, &div/2))
      |> assign(:minutes, format_time(assigns.move_timer, &rem/2))

    ~H"""
    <div class="">
      <.player_info
        user_online?={@user_online?}
        game={@game}
        displayed_user_type={@displayed_user_type}
        hours={@hours}
        minutes={@minutes}
      >
      </.player_info>
      <Gobbler.list
        game={@game}
        current_user_type={@current_user_type}
        displayed_user_type={@displayed_user_type}
        color={@color}
        class={@class}
      />
    </div>
    """
  end

  def player_info(assigns) do
    ~H"""
    <div class="flex justify-between bg-gray-700 text-white">
      <div class="flex items-baseline pl-2">
        <UserStatus.show user_online?={@user_online?} />
        <p class="mx-0.5">
          <%= show_player_name(@game, @displayed_user_type) %>
        </p>
        <.badge class="mx-0.5 h-full" color={get_current_user_color_type(@displayed_user_type)}>
          <%= @displayed_user_type %>
        </.badge>
      </div>
      <div class="text-2xl border-black-500 bg-gray-500 text-white px-2">
        <span><%= @hours %>:</span><span><%= @minutes %></span>
      </div>
    </div>
    """
  end

  defp format_time(ints, converter) do
    ints
    |> converter.(60)
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
