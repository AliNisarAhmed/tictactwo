defmodule TictactwoWeb.Components.Controls do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  alias TictactwoWeb.Components.Button

  def panel(assigns) do
    ~H"""
      <div class="flex">
        <%= if game_in_play?(@game) do %>
          <Button.abort_game />
        <% else %>
          <%= if rematch_offered?(@game, @current_user, @user_type) do %> 
            <Button.accept_rematch />
          <% else %> 
            <Button.offer_rematch current_user={@current_user} user_type={@user_type}/>
          <% end %>
        <% end %>
      </div>
    """
  end
end
