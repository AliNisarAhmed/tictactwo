defmodule Tictactwo.Types do
  defmacro __using__(_opts) do
    quote do
      @type game_status() ::
              :ready
              | :in_play
              | :blue_won
              | :orange_won
              | {:aborted, String.t()}
              | {:resigned, String.t()}
      @type player() :: :blue | :orange
      @type gobbler_name() :: :xl | :large | :medium | :small | :xs | :premie
      @type gobbler() :: %{
              name: gobbler_name(),
              status: gobbler_status()
            }
      @type cells :: [cell()]
      @type cell() :: %{
              coords: coords(),
              gobblers: [{player(), gobbler_name()}]
            }
      @type row :: pos_integer()
      @type col :: pos_integer()
      @type coords :: {row(), col()}
      @type gobbler_status :: :not_selected | :selected | {:played, coords()}
      @type selected_gobbler ::
              nil
              | %{
                  name: gobbler_name(),
                  played?: coords() | nil
                }
      @type slug :: String.t()
      @type game :: %{
              slug: slug(),
              status: game_status(),
              player_turn: player(),
              blue_username: String.t(),
              orange_username: String.t(),
              blue: [gobbler()],
              orange: [gobbler()],
              cells: [cell()],
              selected_gobbler: selected_gobbler(),
              timers: %{
                blue: pos_integer(),
                orange: pos_integer()
              },
              match: match()
            }
      @type match :: %{
              status: match_status(),
              time_per_move: pos_integer(),
              scores: %{
                String.t() => pos_integer()
              }
            }
      @type match_status :: :in_play | :transition | :match_over
      @type viewer_type :: :blue | :orange | :spectator
      @type current_user :: %{
              username: String.t(),
              id: String.t()
            }
      @type challenge_status :: :challenge_sent | nil
      @type table :: %{
              owner: String.t(),
              owner_id: String.t(),
              owner_color: player()
            }
    end
  end
end
