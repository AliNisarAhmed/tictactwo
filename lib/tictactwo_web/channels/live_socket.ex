defmodule TictactwoWeb.LiveSocket do
  @moduledoc """
  The LiveView socket for Phoenix Endpoints.
  """
  use Phoenix.Socket

  defstruct id: nil,
            endpoint: nil,
            parent_pid: nil,
            assigns: %{},
            changed: %{},
            fingerprints: {nil, %{}},
            private: %{},
            stopped: nil,
            connected?: false

  channel "lv:*", Phoenix.LiveView.Channel
  channel "event_bus:*", PhatWeb.LobbyChannel

  @doc """
  Connects the Phoenix.Socket for a LiveView client.
  """
  # @impl Phoenix.Socket
  # # def connect(_params, socket, _connect_info) do
  # #   {:ok, socket}
  # # end

  @doc """
  Identifies the Phoenix.Socket for a LiveView client.
  """
  # @impl Phoenix.Socket
  # def id(_socket), do: nil

  @impl Phoenix.Socket
  def connect(_params, %Phoenix.Socket{} = socket, connect_info) do
    {:ok, put_in(socket.private[:connect_info], connect_info)}
  end

  @impl Phoenix.Socket
  def id(socket), do: socket.private.connect_info[:session]["live_socket_id"]
end
