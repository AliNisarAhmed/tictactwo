defmodule TictactwoWeb.UserAuth do
  import Plug.Conn

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
      username:
        "Anonymous_#{Faker.Person.first_name()}_#{Faker.Random.Elixir.random_between(10_000, 999_999)}"
    }
  end
end
