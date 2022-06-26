defmodule TictactwoWeb.LobbyController do
  use TictactwoWeb, :controller

  alias Phoenix.LiveView
  alias TictactwoWeb.LobbyControllerLive
  alias Faker.Internet

  def show(conn, _assigns) do
    LiveView.Controller.live_render(
      conn,
      LobbyControllerLive,
      session: %{
        "current_user" => generate_random_user()
      }
    )
  end

  defp generate_random_user() do
    id = Ecto.UUID.generate()

    %{
      id: id,
      username: Internet.user_name()
    }
  end
end
