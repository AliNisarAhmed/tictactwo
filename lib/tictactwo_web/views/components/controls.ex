defmodule TictactwoWeb.Components.Controls do
  use Phoenix.Component

  import TictactwoWeb.RoomView

  alias TictactwoWeb.Components.Button

  attr :game, :map, required: true
  attr :current_user, :map, required: true
  attr :user_type, :atom, required: true, values: [:blue, :orange, :spectator]

  def panel(assigns) do
    assigns =
      assigns
      |> assign(:game_ended?, game_ended?(assigns.game))
      |> assign(
        :rematch_offered?,
        rematch_offered?(assigns.game, assigns.current_user, assigns.user_type)
      )

    ~H"""
      <div class="flex">
        <Button.abort_game :if={game_ready?(@game)} current_user={@current_user} />
        <Button.resign_game :if={game_in_play?(@game)} current_user={@current_user}/>
        <Button.accept_rematch :if={@game_ended? && @rematch_offered?}/>
        <Button.offer_rematch :if={@game_ended? and not @rematch_offered?} current_user={@current_user} user_type={@user_type}/>
        <Button.back_to_lobby :if={@game_ended?}/>
      </div>
    """
  end
end
