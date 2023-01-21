defmodule TictactwoWeb.Components.Player do
  use Phoenix.Component

  import TictactwoWeb.RoomView
  import PetalComponents.Badge

  alias TictactwoWeb.Components.Gobbler

  attr :game, :map, required: true
  attr :color, :string, required: true, values: ["primary", "secondary"]
  attr :move_timer, :map, required: true
  attr :current_user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :displayed_user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :class, :string, default: ""

  def info(assigns) do
    assigns =
      assigns
      |> assign(:hours, format_time(assigns.move_timer, &div/2))
      |> assign(:minutes, format_time(assigns.move_timer, &rem/2))

    ~H"""
      <div>
        <div class="flex justify-between">
          <span>
            <%= show_player_name(@game, @displayed_user_type) %> 
          <.badge color={get_current_user_color_type(@displayed_user_type)}>
           <%= @displayed_user_type %>
          </.badge>
          </span>
          <span>
            <%= @hours %>:<%= @minutes %>
          </span>
        </div>
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

  defp format_time(ints, converter) do
    ints
    |> converter.(60)
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
