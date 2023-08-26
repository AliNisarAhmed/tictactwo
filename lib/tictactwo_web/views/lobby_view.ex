defmodule TictactwoWeb.LobbyView do
  use TictactwoWeb, :view

  alias TictactwoWeb.Components.Button
  alias Phoenix.LiveView.JS

  defp filter_self(users, current_username) do
    Enum.filter(users, fn {_user_id, user_data} -> user_data.username != current_username end)
  end

  defp show_active_content(js \\ %JS{}, tab) do
    js
    |> JS.push("switch-tab", value: %{"tab" => tab})
    |> JS.hide(to: "div.tab-content")
    |> JS.show(
      to: "#content-tab-#{tab}",
      transition: {"ease-out duration-300", "opacity-0", "opacity-100"},
      time: 300
    )
  end

  def player_has_table?(tables, username) do
    tables
    |> Enum.any?(fn table -> table.owner == username end)
  end

  def player_owns_table?(table, username) do
    table.owner == username
  end
end
