defmodule Tictactwo.Presence do
  use Phoenix.Presence, otp_app: :tictactwo, pubsub_server: Tictactwo.PubSub

  alias Tictactwo.Presence

  def list_presences(topic) do
    Presence.list(topic)
    |> Enum.reduce(%{}, fn {user_id, %{metas: [meta | _]}}, acc ->
      acc
      |> Map.put(
        user_id,
        meta
        |> Map.put(:status, nil)
      )
    end)
  end
end
