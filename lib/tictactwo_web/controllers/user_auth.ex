defmodule TictactwoWeb.UserAuth do
  import Plug.Conn
  alias Faker.Internet

  def populate_current_user(conn, _opts) do
    current_user = get_session(conn, "current_user")

    if current_user do
      conn
    else
      current_user = generate_random_user()

      conn
      |> put_session("current_user", current_user)
      |> assign(:current_user, current_user)
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
