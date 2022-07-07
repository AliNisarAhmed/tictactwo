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

  def accept(assigns) do
    ~H"""
      <button
          phx-click="accept-challenge"
          phx-value-challenger={@challenger}
          class="px-2 py-1 bg-green-500 rounded-xl text-white cursor-pointer mr-1"
      >
        <%= @text %>
      </button>
    """
  end

  def reject(assigns) do
    ~H"""
      <button
          phx-click="reject-challenge"
          phx-value-challenger={@challenger}
          class="px-2 py-1 bg-red-500 rounded-xl text-white cursor-pointer"
      >
        <%= @text %>
      </button>
    """
  end
end
