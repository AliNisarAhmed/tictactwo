defmodule TictactwoWeb.Components.Button do
  use Phoenix.Component

  import PetalComponents.Button

  def challenge(assigns) do
    ~H"""
      <.button
          color="primary"
          variant="outline"
          size="lg"
          phx-click="challenge-user"
          phx-value-userid={@user_id}
      >
        <%= if @user_data.status == :challenge_sent do %>
          Cancel?
        <% else %> 
          Challenge
        <% end %>
      </.button>
    """
  end

  def accept_challenge(assigns) do
    ~H"""
      <.button
          color="success"
          variant="outline"
          phx-click="accept-challenge"
          phx-value-challenger-username={@challenge.username}
          phx-value-challenger-id={@challenge.id}
      >
        <%= @text %>
      </.button>
    """
  end

  def reject_challenge(assigns) do
    ~H"""
      <.button
          color="danger"
          variant="outline"
          phx-click="reject-challenge"
          phx-value-challenger_username={@challenge.username}
          phx-value-challenger_id={@challenge.id}
      >
        <%= @text %>
      </.button>
    """
  end

  def accept_rematch(assigns) do
    ~H"""
      <.button 
        color="success"
        phx-click="rematch-accepted"
      >
        Accept Rematch
      </.button>
    """
  end

  def offer_rematch(assigns) do
    ~H"""
      <.button 
        color="primary"
        phx-click="offer-rematch"
        phx-value-username={@current_user.username}
        phx-value-color={@user_type}
      >
        Rematch
      </.button>
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
