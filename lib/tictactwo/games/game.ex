defmodule Tictactwo.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tictactwo.EctoErlangBinary

  schema "games" do
    field :blue, :string
    field :orange, :string
    field :player_turn, Ecto.Enum, values: [:blue, :orange]
    field :slug, :string
    field :status, Ecto.Enum, values: [:in_play, :won]
    field :cells, EctoErlangBinary
    field :blue_gobblers, EctoErlangBinary
    field :orange_gobblers, EctoErlangBinary

    timestamps()
  end

  @doc false
  def create_changeset(game, attrs) do
    game
    |> cast(attrs, [:blue, :orange, :player_turn, :cells, :blue_gobblers, :orange_gobblers])
    |> IO.inspect
    |> put_change(:slug, generate_slug())
    |> put_change(:status, :in_play)

    |> IO.inspect
    |> validate_required([
      :blue,
      :orange,
      :player_turn,
      :cells,
      :blue_gobblers,
      :orange_gobblers
    ])
  end

  defp generate_slug(length \\ 12) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
