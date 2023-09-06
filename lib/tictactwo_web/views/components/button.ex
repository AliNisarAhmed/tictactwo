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
      Accept Rematch?
    </.button>
    """
  end

  attr(:current_user, :map, required: true)
  attr(:user_type, :atom, required: true, values: [:blue, :orange, :spectator])

  def offer_rematch(assigns) do
    ~H"""
    <.button
      id="offer-rematch"
      color="primary"
      variant="outline"
      class="border-none"
      phx-click="offer-rematch"
      phx-click={
        JS.hide(to: "#offer-rematch")
        |> JS.show(to: "#rematch-offered")
        |> JS.push("offer-rematch",
          value: %{
            "username" => @current_user.username,
            "color" => @user_type
          }
        )
      }
      phx-value-username={@current_user.username}
      phx-value-color={@user_type}
      title="Offer Rematch"
    >
      <Heroicons.arrow_path class="w-6 h-6 stroke-green-600" />
    </.button>
    <.button
      color="primary"
      variant="outline"
      class="hidden border-none"
      id="rematch-offered"
      phx-click={JS.hide() |> JS.show(to: "#offer-rematch")}
    >
      <Heroicons.arrow_path class="w-6 h-6 stroke-green-400 animate-spin" />
    </.button>
    """
  end

  def rematch_offered(assigns) do
    ~H"""

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
      class="border-none"
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
      class="hidden border-none bg-orange-500"
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
      class="border-none"
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
      class="hidden border-none bg-orange-500"
    >
      <HeroiconsV1.Outline.flag id="resign-icon-full" class="w-6 h-6 fill-orange stroke-white" />
    </.button>
    """
  end

  def back_to_lobby(assigns) do
    ~H"""
    <.button
      title="Back to Lobby"
      color="warning"
      variant="outline"
      class="border-none"
      phx-click="back-to-lobby"
    >
      <Heroicons.arrow_right_on_rectangle class="w-6 h-6 stroke-orange-600" />
    </.button>
    """
  end
end
