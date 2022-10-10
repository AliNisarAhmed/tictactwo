defmodule TictactwoWeb.Components.Controls do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  alias TictactwoWeb.Components.Button

  def panel(assigns) do
    ~H"""
      <div class="flex">
        <%= if game_ended?(@game) do %> 
          <Button.back_to_lobby />
        <% else %>
          
          <%= if game_ready?(@game) do %>
            <Button.abort_game current_user={@current_user} />
          <% else %>
            <%= if game_in_play?(@game) do %>
              <Button.resign_game current_user={@current_user}/>
            <% else %>
              <%= if rematch_offered?(@game, @current_user, @user_type) do %> 
                <Button.accept_rematch />
                <Button.back_to_lobby />
              <% else %> 
                <Button.offer_rematch current_user={@current_user} user_type={@user_type}/>
                <Button.back_to_lobby />
              <% end %>
            <% end %>
          <% end %>
        <% end %>
      </div>
    """
  end
end
