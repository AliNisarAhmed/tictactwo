defmodule TictactwoWeb.Components.Player do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  alias TictactwoWeb.Components.Gobbler

  def info(assigns) do
    assigns =
      assigns
      |> assign(:hours, format_time(assigns.move_timer, &div/2))
      |> assign(:minutes, format_time(assigns.move_timer, &rem/2))

    ~H"""
      <div>
        <div class="flex justify-between">
          <span>
            <%= show_player_name(@game, @color) %> 
          </span>
          <span>
            <%= @hours %>:<%= @minutes %>
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

  defp format_time(ints, converter) do
    ints
    |> converter.(60)
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
