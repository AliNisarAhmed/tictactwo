defmodule TictactwoWeb.LobbyController do
  use TictactwoWeb, :controller

  alias Phoenix.LiveView
  alias TictactwoWeb.LobbyControllerLive
  alias Faker.Internet

  def show(conn, _params) do
    current_user = get_session(conn, "current_user")

    current_user
    |> IO.inspect(label: "CURRENT USER COOKIE")

    if is_nil(current_user) do
      current_user = generate_random_user()

      conn =
        conn
        |> put_session(
          "current_user",
          current_user
        )

      LiveView.Controller.live_render(
        conn,
        LobbyControllerLive,
        session: %{
          "current_user" => current_user
        }
      )
    else
      LiveView.Controller.live_render(
        conn,
        LobbyControllerLive,
        session: %{
          "current_user" => current_user
        }
      )
    end
  end

  defp generate_random_user() do
    id = Ecto.UUID.generate()

    %{
      id: id,
      username: Internet.user_name()
    }
  end
end
