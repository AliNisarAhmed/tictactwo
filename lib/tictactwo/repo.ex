defmodule Tictactwo.Repo do
  use Ecto.Repo,
    otp_app: :tictactwo,
    adapter: Ecto.Adapters.Postgres
end
