defmodule Tictactwo.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tictactwo.EctoErlangBinary

  schema "games" do
    field :blue_username, :string
    field :orange_username, :string
    field :player_turn, Ecto.Enum, values: [:blue, :orange]
    field :slug, :string
    field :status, Ecto.Enum, values: [:in_play, :blue_won, :orange_won]
    field :cells, EctoErlangBinary
    field :blue, EctoErlangBinary
    field :orange, EctoErlangBinary

    timestamps()
  end

  @doc false
  def create_changeset(game, attrs) do
    game
    |> cast(attrs, [:blue_username, :orange_username, :player_turn, :cells, :blue, :orange])
    |> put_change(:slug, generate_slug())
    |> put_change(:status, :in_play)
    |> validate_required([
      :blue_username,
      :orange_username,
      :player_turn,
      :cells,
      :blue,
      :orange
    ])
  end

  defp generate_slug(length \\ 12) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
