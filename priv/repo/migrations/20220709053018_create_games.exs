defmodule Tictactwo.Repo.Migrations.CreateGames do
  use Ecto.Migration

  @timestamp_opts [type: :utc_datetime_usec, usec: true]

  def change do
    create table(:games) do
      add :blue, :string
      add :orange, :string
      add :slug, :string, null: false
      add :status, :string, null: false
      add :player_turn, :string
      add :cells, :binary, null: false
      add :blue_gobblers, :binary, null: false
      add :orange_gobblers, :binary, null: false

      timestamps(@timestamp_opts)
    end

    create unique_index(:games, [:slug])
  end
end
