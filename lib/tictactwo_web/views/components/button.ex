defmodule TictactwoWeb.Components.Button do
  use Phoenix.Component

  def challenge(assigns) do
    ~H"""
      <button
          phx-click="challenge-user"
          phx-value-userid={@user_id}
          class="px-4 py-2 bg-orange-500 rounded-xl text-white cursor-pointer"
      >
        <%= if @user_data.status == :challenge_sent do %>
    					Challenge sent
    		<% else %>
    					Challenge!
    		<% end %>
      </button>
    """
  end

  def accept_challenge(assigns) do
    ~H"""
      <button
          phx-click="accept-challenge"
          phx-value-challenger_username={@challenge.username}
          phx-value-challenger_id={@challenge.id}
          class="px-2 py-1 bg-green-500 rounded-xl text-white cursor-pointer mr-1"
      >
        <%= @text %>
      </button>
    """
  end

  def reject_challenge(assigns) do
    ~H"""
      <button
          phx-click="reject-challenge"
          phx-value-challenger_username={@challenge.username}
          phx-value-challenger_id={@challenge.id}
          class="px-2 py-1 bg-red-500 rounded-xl text-white cursor-pointer"
      >
        <%= @text %>
      </button>
    """
  end

  def accept_rematch(assigns) do
    ~H"""
      <button 
        phx-click="rematch-accepted"
      >
        Accept Rematch
      </button>
    """
  end

  def offer_rematch(assigns) do
    ~H"""
      <button 
        phx-click="offer-rematch"
        phx-value-username={@current_user.username}
        phx-value-color={@user_type}
      >
        Rematch
      </button>
    """
  end

  def abort_game(assigns) do 
    ~H"""
      <button 
        phx-click="abort-game"
        phx-value-username={@current_user.username}
      >
        Abort Game
      </button>
    """
  end

  def back_to_lobby(assigns) do 
    ~H"""
      <button 
        phx-click="back-to-lobby"
      >
        Back to Lobby
      </button>
    """
  end
end
