defmodule TictactwoWeb.Components.Gobbler do
  use Phoenix.Component
  use Tictactwo.Types

  import TictactwoWeb.RoomView
  alias Tictactwo.Games

  attr :game, :map, required: true
  attr :current_user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :displayed_user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :color, :string, required: true
  attr :class, :string, default: ""

  # <div>
  #   <.selected
  #     game={@game}
  #     current_user_type={@current_user_type}
  #     displayed_user_type={@displayed_user_type}
  #     color={@color}
  #   />
  # </div>

  def list(assigns) do
    ~H"""
    <div class="flex flex-row w-screen max-w-screen-sm">
      <%= for gobbler <- not_selected_gobblers(@game, @displayed_user_type) do %>
        <.list_item
          game={@game}
          current_user_type={@current_user_type}
          displayed_user_type={@displayed_user_type}
          gobbler={gobbler}
          color={@color}
          class={@class}
        />
      <% end %>
    </div>
    """
  end

  attr :current_user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :displayed_user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :game, :map, required: true
  attr :gobbler, :map, required: true
  attr :color, :string, required: true
  attr :class, :string, default: ""

  def list_item(%{gobbler: %{status: {:played, _}}} = assigns) do
    ~H"""
    <div class="h-full w-full border-2 border-sky-500"></div>
    """
  end

  def list_item(%{gobbler: %{status: :selected}} = assigns) do
    ~H"""
    <button
      disabled={is_button_disabled?(@game, @current_user_type, @displayed_user_type, @gobbler)}
      phx-click="select-gobbler"
      phx-value-gobbler={@gobbler.name}
      class="border-2 border-yellow-500 rounded-lg"
    >
      <.gobbler_image name={@gobbler.name} color={@color} />
    </button>
    """
  end

  def list_item(assigns) do
    ~H"""
    <button
      disabled={is_button_disabled?(@game, @current_user_type, @displayed_user_type, @gobbler)}
      phx-click="select-gobbler"
      phx-value-gobbler={@gobbler.name}
    >
      <.gobbler_image name={@gobbler.name} color={@color} />
    </button>
    """
  end

  attr :current_user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :displayed_user_type, :atom, required: true, values: [:blue, :orange, :spectator]
  attr :game, :map, required: true
  attr :color, :string, required: true

  def selected(assigns) do
    ~H"""
    <button
      phx-click="deselect-gobbler"
      disabled={is_selected_disabled?(@game, @current_user_type, @displayed_user_type)}
    >
      <%= if not is_nil(@game.selected_gobbler) and my_turn?(@game, @displayed_user_type) do %>
        <.gobbler_image name={@game.selected_gobbler.name} color={@color} />
      <% end %>
    </button>
    """
  end

  attr :game, :map, required: true
  attr :cell, :map, required: true
  attr :on_click, :string, required: false, default: ""
  attr :disabled, :boolean, required: false, default: false
  attr :class, :string, required: false, default: ""

  def board_item(assigns) do
    assigns =
      assigns
      |> assign(:first_gobbler, first_gobbler(assigns.cell.gobblers))

    ~H"""
    <%= if @first_gobbler do %>
      <button
        phx-click={@on_click}
        phx-value-gobbler={@first_gobbler.name}
        phx-value-row={elem(assigns.cell.coords, 0)}
        phx-value-col={elem(assigns.cell.coords, 1)}
        disabled={@disabled}
        class={"w-full h-full #{@class}"}
      >
        <.gobbler_image
          name={@first_gobbler.name}
          color={get_current_user_color_type(@first_gobbler.color)}
        />
      </button>
    <% end %>
    """
  end

  attr :game, :map, required: true
  attr :cell, :map, required: true
  attr :current_user_type, :atom, required: true, values: [:blue, :orange, :spectator]

  def board_item_selected(assigns) do
    assigns =
      assigns
      |> assign(:my_turn, my_turn?(assigns.game, assigns.current_user_type))
      |> assign(:move_allowed, Games.move_allowed?(assigns.game, assigns.cell.gobblers))
      |> assign(:played_gobbler_color, played_gobbler_color(assigns.cell.gobblers))
      |> assign(:row_value, elem(assigns.cell.coords, 0))
      |> assign(:col_value, elem(assigns.cell.coords, 1))
      |> assign(:first_gobbler, first_gobbler(assigns.cell.gobblers))
      |> assign(
        :first_gobbler_selected,
        first_gobbler_selected?(
          assigns.game,
          assigns.cell.coords
        )
      )

    ~H"""
    <%= if is_nil(@first_gobbler) do %>
      <.item_selected_button
        row_value={@row_value}
        col_value={@col_value}
        disabled={not @my_turn}
        class={if @my_turn, do: "cursor-pointer"}
      >
      </.item_selected_button>
    <% else %>
      <%= if @first_gobbler_selected do %>
        <.item_selected_button
          row_value={@row_value}
          col_value={@col_value}
          disabled={not @my_turn}
          class={"hidden #{if @my_turn, do: "cursor-pointer"}"}
        >
        </.item_selected_button>
      <% else %>
        <.item_selected_button
          row_value={@row_value}
          col_value={@col_value}
          disabled={not @move_allowed}
          class={if @my_turn and @move_allowed, do: "cursor-pointer", else: "cursor-not-allowed"}
        >
          <.gobbler_image
            name={@first_gobbler.name}
            color={get_current_user_color_type(@first_gobbler.color)}
          />
        </.item_selected_button>
      <% end %>
    <% end %>
    """
  end

  attr :row_value, :integer, required: true
  attr :col_value, :integer, required: true
  attr :disabled, :boolean, required: true
  attr :class, :string, required: false, default: ""
  slot(:inner_block, required: true)

  def item_selected_button(assigns) do
    ~H"""
    <button
      phx-click="play-gobbler"
      phx-value-row={@row_value}
      phx-value-col={@col_value}
      disabled={@disabled}
      class={"w-full h-full #{@class}"}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :name, :string, required: true
  attr :color, :string, required: true

  def gobbler_image(assigns) do
    assigns =
      assigns
      |> assign(:gobbler_file, "#{assigns.name}-#{assigns.color}")

    ~H"""
    <%= PhoenixInlineSvg.Helpers.svg_image(TictactwoWeb.Endpoint, @gobbler_file,
      class: "w-full h-full"
    ) %>
    """
  end

  @spec is_button_disabled?(game(), viewer_type(), viewer_type(), gobbler()) :: boolean()
  defp is_button_disabled?(game, current_user_type, displayed_user_type, gobbler) do
    not my_turn?(game, current_user_type) or
      (not is_nil(game.selected_gobbler) and game.selected_gobbler.name == gobbler.name) or
      current_user_type != displayed_user_type or
      game_ended?(game)
  end

  defp is_selected_disabled?(game, current_user, display_user) do
    not my_turn?(game, current_user) ||
      is_nil(game.selected_gobbler) ||
      current_user != display_user ||
      game_ended?(game)
  end
end
