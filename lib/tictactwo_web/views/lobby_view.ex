defmodule TictactwoWeb.LobbyView do
  use TictactwoWeb, :view

  defp filter_self(users, current_username) do
    Enum.filter(users, fn {_user_id, user_data} -> user_data.username != current_username end)
  end

  defp show_username(%{username: username}), do: username
end
