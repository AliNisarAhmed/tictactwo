defmodule TictactwoWeb.Components.UserStatus do
  use Phoenix.Component

  def show(assigns) do
    bg_color = if assigns.user_online?, do: "bg-green-500", else: "bg-red-500"
    assigns = assign(assigns, :bg_color, bg_color)

    ~H"""
    <div class={"w-2 h-2 rounded-full #{@bg_color}"}></div>
    """
  end
end
