defmodule Tictactwo.Repo.Migrations.CreateGames do
  use Ecto.Migration

  @timestamp_opts [type: :utc_datetime_usec, usec: true]

  def change do
    create table(:games) do
      add :blue_username, :string
      add :orange_username, :string
      add :slug, :string, null: false
      add :status, :string, null: false
      add :player_turn, :string
      add :cells, :binary, null: false
      add :blue, :binary, null: false
      add :orange, :binary, null: false

      timestamps(@timestamp_opts)
    end

    create unique_index(:games, [:slug])
  end
end
