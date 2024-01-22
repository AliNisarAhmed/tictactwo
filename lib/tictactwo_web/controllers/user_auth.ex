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
      username: "Anon_#{Faker.Person.first_name()}_#{generate_number()}"
    }
  end

  defp generate_number() do
    Faker.Random.Elixir.random_between(1, 999)
    |> Integer.to_string()
    |> String.pad_leading(3, "00")
  end
end
