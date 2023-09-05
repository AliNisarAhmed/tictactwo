defmodule TictactwoWeb.Components.Button do
  use Phoenix.Component

  import PetalComponents.Button
  alias Phoenix.LiveView.JS
  alias PetalComponents.HeroiconsV1

  attr(:user_id, :integer, required: true)
  attr(:user_data, :map, required: true)

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

  attr(:challenge, :map, required: true)
  attr(:text, :string, required: true)

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

  attr(:challenge, :map, required: true)
  attr(:text, :string, required: true)

  def reject_challenge(assigns) do
    ~H"""
    <.button
      color="danger"
      variant="outline"
      phx-click="reject-challenge"
      phx-value-challenger-username={@challenge.username}
      phx-value-challenger-id={@challenge.id}
    >
      <%= @text %>
    </.button>
    """
  end

  def accept_rematch(assigns) do
    ~H"""
    <.button color="success" phx-click="rematch-accepted">
      Accept Rematch
    </.button>
    """
  end

  attr(:current_user, :map, required: true)
  attr(:user_type, :atom, required: true, values: [:blue, :orange, :spectator])

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

  attr(:current_user, :map, required: true)

  def abort_game(assigns) do
    ~H"""
    <.button
      id="abort-button-client"
      color="danger"
      variant="outline"
      phx-click={JS.hide() |> JS.show(to: "#abort-button")}
      phx-value-username={@current_user.username}
      class="border-0"
    >
      <HeroiconsV1.Outline.x class="w-6 h-6" />
    </.button>
    <.button
      id="abort-button"
      color="danger"
      variant="outline"
      phx-click="abort-game"
      phx-click-away={JS.hide() |> JS.show(to: "#abort-button-client")}
      phx-value-username={@current_user.username}
      class="hidden border-0 bg-orange-500"
    >
      <HeroiconsV1.Outline.x class="w-6 h-6 fill-orange stroke-white" />
    </.button>
    """
  end

  attr(:current_user, :map, required: true)

  def resign_game(assigns) do
    ~H"""
    <.button
      id="resign-button-client"
      color="danger"
      variant="outline"
      phx-click={
        JS.hide()
        |> JS.show(to: "#resign-button")
      }
      class="border-0"
    >
      <HeroiconsV1.Outline.flag id="resign-icon" class="w-6 h-6" />
    </.button>
    <.button
      id="resign-button"
      color="danger"
      variant="outline"
      phx-click="resign-game"
      phx-click-away={JS.hide() |> JS.show(to: "#resign-button-client")}
      phx-value-username={@current_user.username}
      class="hidden border-0 bg-orange-500"
    >
      <HeroiconsV1.Outline.flag id="resign-icon-full" class="w-6 h-6 fill-orange stroke-white" />
    </.button>
    """
  end

  def back_to_lobby(assigns) do
    ~H"""
    <.button color="info" phx-click="back-to-lobby">
      Back to Lobby
    </.button>
    """
  end
end
