defmodule TictactwoWeb.LobbyChannel do
  use Phoenix.Channel

  def join("event_bus:" <> _user_id, _message, socket) do
    {:ok, socket}
  end
end
